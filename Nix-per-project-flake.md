# Setting up per-project Nix flakes (2025–2026 best practice)

Goal: each project has its own isolated development environment  
→ different versions of tools/languages/libraries per folder  
→ automatic activation when you `cd` into the folder

## Recommended stack

- Home Manager (global/user tools)
- `direnv` + `nix-direnv` (auto-activation)
- `flake.nix` + `devShell` per project

## 1. Global setup (do once)

You should already have these in `~/.config/home-manager/home.nix`:

```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;          # ← very important (fast reloads)
};

# Optional but very useful
programs.zsh.shellAliases = {
  nd  = "nix develop";
  nds = "nix develop --impure --no-pure-eval";  # emergency escape hatch
};