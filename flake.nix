# ~/.config/home-manager/flake.nix
{
  description = "My Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-argocd-fix = {
      url = "github:nixos/nixpkgs/12f3e06fb8f4bd9db1965b3b24fb0171b75891a0";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-argocd-fix, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;                  # ← allow all unfree
        # Or more precise (only allow terraform):
        # config.allowUnfreePredicate = pkg:
        #   builtins.elem (nixpkgs.lib.getName pkg) [ "terraform" ];
        overlays = [
          (final: prev: {
            argocd = (import nixpkgs-argocd-fix {
              inherit system;
              config.allowUnfree = true;
            }).argocd;
          })
          # mitmproxy: relax deps + skip tests (pytest vs pyproject.toml conflict on current nixpkgs)
          (final: prev: {
            mitmproxy = prev.mitmproxy.overridePythonAttrs (old: {
              pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [
                "aioquic" "asgiref" "pyparsing" "ruamel.yaml" "tornado" "wsproto"
              ];
              doCheck = false;
            });
          })
        ];
      };    
    in {
      homeConfigurations."daveli" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # No homeDirectory or username here anymore!
        modules = [
          ./home.nix
          # You can add more modules here later, e.g. ./modules/git.nix
        ];

        # extraSpecialArgs = { inherit self; };  # uncomment if a module needs flake self
      };
    };
}
