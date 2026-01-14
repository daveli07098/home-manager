# Minimal flake.nix for a per-project development shell

Put this `flake.nix` directly inside your project folder.

After adding it, create `.envrc` with:

```bash
use flake

direnv allow

```


{
  description = "Minimal dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # ← Replace these with whatever THIS project needs
            # nodejs_20           # example: Node.js
            # python312           # example: Python 3.12
            # rustc cargo         # example: Rust
            # go                  # example: Go
            # zig                 # example: Zig
          ];

          shellHook = ''
            echo
            echo "  → Minimal dev shell active"
            echo
          '';
        };
      }
    );
}



Quick usage checklist

Place flake.nix in project root
Create .envrc containing only:textuse flake
Run direnv allow (only once)
cd in → tools appear
cd .. → tools disappear