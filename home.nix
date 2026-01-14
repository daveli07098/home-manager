{ config, pkgs, ... }:

{
  home.username = "daveli";
  home.homeDirectory = "/Users/daveli";
  home.stateVersion = "25.11";  # Good choice for recent compatibility

  home.packages = with pkgs; [
    neovim ripgrep fd bat eza fzf git
    # helix tmux direnv just ... add more here later
  ];

  programs = {
    git.enable = true;

    # ─── Add these two blocks ───
    home-manager.enable = true;  # Lets HM manage itself + some helpers

    zsh = {
      enable = true;
      # Optional extras (uncomment as you want)
      # enableCompletion = true;
      # autosuggestion.enable = true;
      # syntaxHighlighting.enable = true;
      shellAliases = {
        hms  = "home-manager switch --flake ~/.config/home-manager";
        hmg  = "home-manager generations";
        hmr  = "home-manager generations | head -n 1 | cut -d' ' -f1 | xargs home-manager remove-generations";  # remove oldest if needed
      };
      
      # Append your existing custom config at the end
      initExtra = ''
        # Source my hand-managed custom zshrc (keep manual edits here)
        if [ -f ~/.zshrc.custom ]; then
          source ~/.zshrc.custom
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
