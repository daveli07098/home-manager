# Home Manager Configuration

User configuration managed with [Home Manager](https://github.com/nix-community/home-manager) and Nix flakes.

## Quick start

Follow these steps in order. After setup, use `hms` to apply changes.

---

### 0. macOS only: Install Xcode Command Line Tools

Nix needs `git` to use this flake. On macOS, install the developer tools first:

```bash
xcode-select --install
```

A dialog will appear; click **Install** and wait for it to finish. Then restart your terminal.

---

### 1. Install Nix

```bash
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

Restart your terminal (or run `source ~/.nix-profile/etc/profile.d/nix.sh`) after installation.

---

### 2. Enable flakes

Create `~/.config/nix/nix.conf`:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

---

### 3. Apply this configuration

From this directory:

```bash
nix run nixpkgs#home-manager -- switch --flake .
```

---

### 4. (Optional) Symlink for `hms` alias

The config defines `hms` as a shortcut to switch. It expects `~/.config/home-manager` to point here:

```bash
mkdir -p ~/.config
ln -sfn "$(pwd)" ~/.config/home-manager
```

Then open a new shell. After that, run `hms` anytime to apply changes.

---

### 5. (Optional) Import agents skills into Cursor

Sync the bundled skills to Cursor's user directory so the Agent can use them:

```bash
skillsync
```

This syncs `agents-skills/.cursor/skills/` to `~/.cursor/skills/`, validates them, and prunes removed skills. Run it after pulling changes to keep your Cursor skills up to date.

---

### 6. (Optional) Migrate Cursor profile to a new device

Export on the source device (writes to `cursor/export/`):

```bash
./cursor/cursor-profile-export.sh
```

Transfer the generated tarball from `cursor/export/` to the new device, then import:

```bash
./cursor/cursor-profile-import.sh cursor-profile-YYYYMMDD.tar.gz
```

This migrates User settings, keybindings, extensions, and skills. Restart Cursor after import.

To get a clean extension set before import, run `./cursor/cursor-extensions-clean.sh` first.

**Extensions not installing?** Ensure the `cursor` CLI is available:
- In Cursor: **Cmd+Shift+P** → "Shell Command: Install 'cursor' command in PATH"
- Quit Cursor before running the import script
- The script will fall back to `/Applications/Cursor.app/.../bin/cursor` if it's not in PATH

---

## Usage

| Command       | Description              |
|---------------|--------------------------|
| `hms`         | Apply config (after symlink) |
| `hmgen`       | List generations         |
| `hmr`         | Keep last 3 generations, remove older |
| `hmpack`      | List installed packages  |
| `hmclean`     | Run garbage collection   |
| `skillsync`   | Sync and validate agents-skills into Cursor |

Without the symlink, use:

```bash
nix run nixpkgs#home-manager -- switch --flake /path/to/home-manager
```
