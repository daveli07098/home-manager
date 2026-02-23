# ~/.config/home-manager/flake.nix
{
  description = "My Home Manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-argocd-fix = {
      url = "github:nixos/nixpkgs/12f3e06fb8f4bd9db1965b3b24fb0171b75891a0";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;                  # ← allow all unfree
        # Or more precise (only allow terraform):
        # config.allowUnfreePredicate = pkg:
        #   builtins.elem (nixpkgs.lib.getName pkg) [ "terraform" ];
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
