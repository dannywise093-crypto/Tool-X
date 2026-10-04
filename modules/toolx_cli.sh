#!/usr/bin/env bash
set -euo pipefail

install_toolx_cli() {
  print_info "Installing toolx launcher"

  mkdir -p "$TOOL_X_BIN"

  cat > "$TOOL_X_BIN/toolx" <<'LAUNCHER'
#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.request

TOOL_X_HOME = os.path.expanduser("~/.tool-x")
CACHE_DIR = os.path.join(TOOL_X_HOME, "cache")
CATALOG_FILE = os.path.join(CACHE_DIR, "data.json")
FAVORITES_FILE = os.path.join(TOOL_X_HOME, "favorites.json")
INSTALLED_FILE = os.path.join(TOOL_X_HOME, "installed.json")
CATALOG_URL = "https://raw.githubusercontent.com/trmxvibs/Tool-X/main/core/data.json"
CACHE_TTL = 24 * 60 * 60

HELP_TEXT = """
Tool-X

Commands:
  toolx              Open the interactive dashboard
  toolx sync         Refresh the full upstream catalog
  toolx search WORD  Search the catalog
  toolx status       Show installed Tool-X components
  toolx doctor       Check the local environment
  toolx tools        Show catalog categories
  toolx favorites    Show favorites
  toolx installed    Show installed Tool-X tools
  toolx help         Show this help

The catalog is synchronized from the public Tool-X database and cached locally.
"""

def clear_screen():
    os.system("clear" if os.name != "nt" else "cls")

def ensure_dirs():
    os.makedirs(CACHE_DIR, exist_ok=True)
    os.makedirs(TOOL_X_HOME, exist_ok=True)

def load_json(path, default):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError):
        return default

def save_json(path, value):
    ensure_dirs()
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(value, f, indent=2, sort_keys=True)
    os.replace(tmp, path)

def sync_catalog(force=False):
    ensure_dirs()
    if not force and os.path.exists(CATALOG_FILE):
        age = time.time() - os.path.getmtime(CATALOG_FILE)
        if age < CACHE_TTL:
            return True

    print("Syncing Tool-X catalog...")
    try:
        request = urllib.request.Request(
            CATALOG_URL,
            headers={"User-Agent": "Tool-X/1.0"}
        )
        with urllib.request.urlopen(request, timeout=20) as response:
            data = json.loads(response.read().decode("utf-8"))
        if not isinstance(data, dict) or not data:
            raise ValueError("catalog is empty or invalid")
        save_json(CATALOG_FILE, data)
        print(f"Catalog synchronized: {len(data)} tools")
        return True
    except Exception as exc:
        if os.path.exists(CATALOG_FILE):
            print(f"Catalog refresh failed; using cached catalog: {exc}")
            return True
        print(f"Catalog refresh failed: {exc}")
        return False

def load_catalog():
    if not sync_catalog():
        return {}
    return load_json(CATALOG_FILE, {})

def normalize_category(value):
    return str(value or "uncategorized").strip() or "uncategorized"

def categories(catalog):
    names = set()
    for info in catalog.values():
        for category in info.get("category", []) or ["uncategorized"]:
            names.add(normalize_category(category))
    return sorted(names, key=str.casefold)

def tool_installed(tool_key):
    installed = load_json(INSTALLED_FILE, {})
    entry = installed.get(tool_key)
    if isinstance(entry, dict):
        path = entry.get("path")
        return bool(path and os.path.exists(path))
    return False

def tool_command_available(info):
    name = info.get("name", "")
    candidates = [name, name.lower().replace(" ", "-")]
    for candidate in candidates:
        if candidate and shutil.which(candidate):
            return True
    return False

def get_package_manager():
    if shutil.which("pkg"):
        return "pkg"
    if shutil.which("apt-get"):
        return "apt-get"
    if shutil.which("apt"):
        return "apt"
    if shutil.which("pacman"):
        return "pacman"
    if shutil.which("dnf"):
        return "dnf"
    if shutil.which("brew"):
        return "brew"
    return None

def install_dependency(dep):
    if not dep or dep in {"bash", "cmd", "powershell"} or shutil.which(dep):
        return True
    manager = get_package_manager()
    if not manager:
        print(f"  Cannot install dependency automatically: {dep}")
        return False

    if manager == "pkg":
        cmd = ["pkg", "install", "-y", dep]
    elif manager in {"apt", "apt-get"}:
        cmd = [manager, "install", "-y", dep]
    elif manager == "pacman":
        cmd = ["pacman", "-S", "--noconfirm", dep]
    elif manager == "dnf":
        cmd = ["dnf", "install", "-y", dep]
    else:
        cmd = ["brew", "install", dep]

    print("  Dependency:", " ".join(cmd))
    return subprocess.run(cmd, check=False).returncode == 0

def install_tool(key, info):
    name = info.get("name", key)
    url = info.get("url")
    manager = info.get("package_manager", "git")
    dependencies = info.get("dependency", []) or []

    if not url:
        print(f"No source URL is recorded for {name}.")
        return False

    for dep in dependencies:
        if not install_dependency(dep):
            print(f"Dependency installation failed: {dep}")
            return False

    safe_name = "".join(c if c.isalnum() or c in "._-" else "_" for c in name)
    destination = os.path.join(TOOL_X_HOME, "tools", safe_name)
    os.makedirs(os.path.dirname(destination), exist_ok=True)

    if manager == "git":
        if os.path.isdir(os.path.join(destination, ".git")):
            cmd = ["git", "-C", destination, "pull", "--ff-only"]
        else:
            if os.path.exists(destination):
                print(f"Destination already exists: {destination}")
                return False
            cmd = ["git", "clone", url, destination]
    elif manager == "curl":
        os.makedirs(destination, exist_ok=True)
        filename = url.rstrip("/").split("/")[-1] or "download"
        cmd = ["curl", "-fL", "-o", os.path.join(destination, filename), url]
    else:
        print(f"Unsupported catalog package manager: {manager}")
        return False

    print("Running:", " ".join(cmd))
    result = subprocess.run(cmd, check=False)
    if result.returncode != 0:
        print(f"Installation failed for {name}.")
        return False

    installed = load_json(INSTALLED_FILE, {})
    installed[key] = {"name": name, "path": destination, "url": url}
    save_json(INSTALLED_FILE, installed)
    print(f"Installed: {name}")
    print(f"Location: {destination}")
    return True

def show_tool(key, info):
    print()
    print(f"Name: {info.get('name', key)}")
    print(f"Description: {info.get('desc', 'No description')}")
    print(f"Source: {info.get('url', 'N/A')}")
    print(f"Category: {', '.join(info.get('category', []) or ['uncategorized'])}")
    print(f"Dependencies: {', '.join(info.get('dependency', []) or [])}")
    print(f"Package manager: {info.get('package_manager', 'git')}")
    print(f"Installed: {'yes' if tool_installed(key) else 'no'}")

def paged_tools(entries, title):
    page_size = 15
    page = 0
    while True:
        clear_screen()
        total_pages = max(1, (len(entries) + page_size - 1) // page_size)
        start = page * page_size
        batch = entries[start:start + page_size]
        print("=" * 72)
        print(f"{title}  |  {len(entries)} tools  |  page {page + 1}/{total_pages}")
        print("=" * 72)
        for i, (key, info) in enumerate(batch, start + 1):
            mark = "✓" if tool_installed(key) else " "
            print(f"{i:>4}. [{mark}] {info.get('name', key)}")
        print()
        print("Commands: number=details/install, i<number>=install, n=next, p=previous, 0=back")
        choice = input("> ").strip().lower()

        if choice == "0":
            return
        if choice == "n":
            if page + 1 < total_pages:
                page += 1
            continue
        if choice == "p":
            if page > 0:
                page -= 1
            continue

        raw = choice[1:] if choice.startswith("i") else choice
        if raw.isdigit():
            number = int(raw)
            if 1 <= number <= len(entries):
                key, info = entries[number - 1]
                if choice.startswith("i"):
                    install_tool(key, info)
                    input("Press Enter to continue...")
                else:
                    clear_screen()
                    show_tool(key, info)
                    action = input("\nInstall this tool? [y/N]: ").strip().lower()
                    if action == "y":
                        install_tool(key, info)
                    input("\nPress Enter to continue...")

def category_menu(catalog):
    cats = categories(catalog)
    while True:
        clear_screen()
        print("=" * 56)
        print("TOOL-X CATEGORIES")
        print("=" * 56)
        for i, category in enumerate(cats, 1):
            count = sum(
                1 for info in catalog.values()
                if category in [normalize_category(x) for x in (info.get("category", []) or ["uncategorized"])]
            )
            print(f"{i:>3}. {category:<40} {count:>4}")
        print("\n  0. Back")
        choice = input("> ").strip()
        if choice == "0":
            return
        if choice.isdigit() and 1 <= int(choice) <= len(cats):
            category = cats[int(choice) - 1]
            entries = [
                (key, info) for key, info in catalog.items()
                if category in [normalize_category(x) for x in (info.get("category", []) or ["uncategorized"])]
            ]
            entries.sort(key=lambda pair: pair[1].get("name", pair[0]).casefold())
            paged_tools(entries, category)

def search_menu(catalog, query=None):
    while True:
        if not query:
            query = input("Search tool name/description/category: ").strip()
        if not query:
            return
        q = query.casefold()
        matches = []
        for key, info in catalog.items():
            haystack = " ".join([
                key,
                str(info.get("name", "")),
                str(info.get("desc", "")),
                " ".join(info.get("category", []) or [])
            ]).casefold()
            if q in haystack:
                matches.append((key, info))
        matches.sort(key=lambda pair: pair[1].get("name", pair[0]).casefold())
        paged_tools(matches, f"SEARCH: {query}")
        return

def favorites_menu(catalog):
    favorites = load_json(FAVORITES_FILE, [])
    entries = [(key, catalog[key]) for key in favorites if key in catalog]
    entries.sort(key=lambda pair: pair[1].get("name", pair[0]).casefold())
    if not entries:
        print("No favorites yet.")
        input("Press Enter...")
        return
    paged_tools(entries, "FAVORITES")

def installed_menu(catalog):
    installed = load_json(INSTALLED_FILE, {})
    entries = [(key, catalog[key]) for key in installed if key in catalog]
    entries.sort(key=lambda pair: pair[1].get("name", pair[0]).casefold())
    if not entries:
        print("No Tool-X tools installed.")
        input("Press Enter...")
        return
    paged_tools(entries, "INSTALLED")

def status():
    print(f"Tool-X home: {TOOL_X_HOME}")
    print(f"Catalog cache: {CATALOG_FILE}")
    print(f"Catalog cached: {'yes' if os.path.exists(CATALOG_FILE) else 'no'}")
    print(f"Installed records: {len(load_json(INSTALLED_FILE, {}))}")
    print(f"Favorites: {len(load_json(FAVORITES_FILE, []))}")

def doctor():
    print("Tool-X environment")
    print("------------------")
    print("Python:", shutil.which("python3") or shutil.which("python") or "not found")
    print("Git:", shutil.which("git") or "not found")
    print("curl:", shutil.which("curl") or "not found")
    print("Package manager:", get_package_manager() or "not found")
    print("Catalog:", CATALOG_FILE if os.path.exists(CATALOG_FILE) else "not cached")

def sync():
    ok = sync_catalog(force=True)
    return 0 if ok else 1

def interactive_menu():
    catalog = load_catalog()
    if not catalog:
        print("Tool-X could not load its catalog.")
        return 1

    while True:
        clear_screen()
        print("=" * 60)
        print("                         TOOL-X")
        print("=" * 60)
        print(f"Catalog: {len(catalog)} tools")
        print()
        print("  1. All tools")
        print("  2. Categories")
        print("  3. Search")
        print("  4. Favorites")
        print("  5. Installed tools")
        print("  6. Sync catalog")
        print("  7. Doctor")
        print("  0. Exit")
        choice = input("\nSelect: ").strip().lower()

        if choice in {"0", "q", "x"}:
            return 0
        if choice == "1":
            entries = sorted(catalog.items(), key=lambda pair: pair[1].get("name", pair[0]).casefold())
            paged_tools(entries, "ALL TOOLS")
        elif choice == "2":
            category_menu(catalog)
        elif choice == "3":
            search_menu(catalog)
        elif choice == "4":
            favorites_menu(catalog)
        elif choice == "5":
            installed_menu(catalog)
        elif choice == "6":
            if sync_catalog(force=True):
                catalog = load_catalog()
            input("Press Enter...")
        elif choice == "7":
            clear_screen()
            doctor()
            input("\nPress Enter...")
        else:
            print("Invalid selection.")
            input("Press Enter...")

def main():
    command = sys.argv[1].lower() if len(sys.argv) > 1 else None

    if command in {"help", "--help", "-h"}:
        print(HELP_TEXT)
        return 0
    if command == "sync":
        return sync()
    if command == "search":
        catalog = load_catalog()
        return search_menu(catalog, " ".join(sys.argv[2:])) or 0
    if command == "status":
        status()
        return 0
    if command == "doctor":
        doctor()
        return 0
    if command == "tools":
        catalog = load_catalog()
        for category in categories(catalog):
            print(category)
        return 0
    if command == "favorites":
        favorites_menu(load_catalog())
        return 0
    if command == "installed":
        installed_menu(load_catalog())
        return 0

    return interactive_menu()

if __name__ == "__main__":
    raise SystemExit(main())
LAUNCHER

  chmod +x "$TOOL_X_BIN/toolx"

  local termux_bin=""
  if command -v bash >/dev/null 2>&1; then
    termux_bin="$(dirname "$(command -v bash)")"
  elif [[ -n "${PREFIX:-}" && -d "$PREFIX/bin" ]]; then
    termux_bin="$PREFIX/bin"
  fi

  if [[ -n "$termux_bin" && -d "$termux_bin" && -w "$termux_bin" ]]; then
    ln -sf "$TOOL_X_BIN/toolx" "$termux_bin/toolx"
    chmod +x "$termux_bin/toolx"
    print_success "Termux launcher linked: $termux_bin/toolx"
  fi

  ensure_path_entry "$TOOL_X_BIN"
  export PATH="$TOOL_X_BIN:$PATH"

  print_success "Launcher installed: $TOOL_X_BIN/toolx"
}
