{ config, pkgs, ... }:

{
  home.username = "daveli";
  home.homeDirectory = "/Users/daveli";
  home.stateVersion = "25.11";  # Good choice for recent compatibility

  home.packages = with pkgs; [
    neovim ripgrep fd bat eza fzf git
    direnv
    nix-direnv
    nixfmt-rfc-style      # formatter for .nix files
    statix                # linter for Nix code
    deadnix               # find dead code in Nix files
    just                  # optional: nice task runner (Justfile)
    # AWS
    awscli2

    # Kubernetes
    kubectl
    kubectx     # fast context/namespace switching
    k9s         # terminal UI for kubernetes (highly recommended)
    # stern     # multi-pod log tailing (optional)
    # krew      # plugin manager for kubectl (optional)

    # Terraform
    terraform
    tflint    # linter (optional but very useful)
    tfsec     # security scanner (optional)
    # terragrunt (optional, if you use it)
  ];

  programs = {
    git.enable = true;

    # ─── Add these two blocks ───
    home-manager.enable = true;  # Lets HM manage itself + some helpers

    zsh = {
      enable = true;
      # Optional extras (uncomment as you want)
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        hms  = "home-manager switch --flake ~/.config/home-manager";
        hmg  = "home-manager generations";
        hmr  = "home-manager generations | head -n 1 | cut -d' ' -f1 | xargs home-manager remove-generations";  # remove oldest if needed
        hmp  = "home-manager packages";
      };
      
      # Append your existing custom config at the end
      initContent = ''
        # Source my hand-managed custom zshrc (keep manual edits here)
        if [ -f ~/.zshrc.custom ]; then
          source ~/.zshrc.custom
        fi
      '';
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      # Optional: show a nice message when entering/leaving env
      stdlib = ''
        show_file() {
          local file=$1
          if [[ -f "$file" ]]; then
            echo "→ Loading $file"
          fi
        }

        show_file ".envrc"
        show_file "flake.nix"
        if [[ -n "$DIRENV_ACTIVE" ]]; then
          echo "→ direnv: activated environment"
        fi
      '';
    };
  };

  # Optional: global env vars (HM will export them)
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  #   VISUAL = "nvim";
  # };
}
