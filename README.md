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

## Usage

| Command       | Description              |
|---------------|--------------------------|
| `hms`         | Apply config (after symlink) |
| `hmgen`       | List generations         |
| `hmr`         | Remove oldest generation |
| `hmpack`      | List installed packages  |
| `hmclean`     | Run garbage collection   |

Without the symlink, use:

```bash
nix run nixpkgs#home-manager -- switch --flake /path/to/home-manager
```
