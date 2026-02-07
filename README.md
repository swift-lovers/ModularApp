# ModularApp

A learning project that demonstrates **modular iOS architecture** using a custom **RepoSync** tool — inspired by real-world large-scale iOS projects.

## Architecture

Instead of git submodules, this project uses a **RepoSync Swift Package Plugin** that manages multiple independent git repositories as modules.

```
ModularApp/                    ← Main repo (this)
├── Module-Config/
│   ├── dev.config             ← Module list + branches (dev)
│   └── prod.config            ← Module list + branches (prod)
├── RepoSync/                  ← Swift Package Plugin
├── git-hooks/                 ← Shared git hooks
├── reposync.sh                ← RepoSync wrapper script
├── git-hook-installer.sh      ← Hook installer
│
├── ModularApp-Core-Network/   ← Cloned by RepoSync (separate repo)
├── ModularApp-Core-UI/        ← Cloned by RepoSync (separate repo)
└── ModularApp-Feature-Home/   ← Cloned by RepoSync (separate repo)
```

## Module Types

| Type | Prefix | Purpose |
|------|--------|---------|
| Core | `ModularApp-Core-*` | Shared infrastructure (networking, UI components) |
| Feature | `ModularApp-Feature-*` | Product features with Clean Architecture |

## Getting Started

### 1. Clone the main repo

```bash
git clone https://github.com/Alesh14/ModularApp.git
cd ModularApp
```

### 2. Run RepoSync to clone all modules

```bash
# Using the wrapper script:
sh reposync.sh

# Or directly:
swift package --package-path RepoSync plugin RepoSync \
  --allow-writing-to-package-directory \
  --allow-writing-to-directory . \
  --allow-network-connections all
```

### 3. Install git hooks

```bash
bash git-hook-installer.sh
```

## Config Format

`Module-Config/dev.config`:
```
ModularApp-Core-Network=master
ModularApp-Core-UI=master
ModularApp-Feature-Home=master
```

Each line is `RepoName=branch` (or tag/commit hash).

## How RepoSync Works

1. **Status Phase**: Checks each module folder — clones if missing, validates if existing
2. **Fetch Phase**: Fetches latest changes from remotes (batched for performance)
3. **Pull Phase**: Checks out target branch/tag and pulls latest

## Adding a New Module

1. Create a new GitHub repo (e.g., `ModularApp-Feature-Settings`)
2. Add it to `Module-Config/dev.config`:
   ```
   ModularApp-Feature-Settings=master
   ```
3. Run `sh reposync.sh` — it will be cloned automatically
