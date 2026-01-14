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
    pre-commit            # git hooks

    # AWS
    awscli2
    # Azure
    azure-cli

    # Kubernetes
    kubectl
    kubernetes-helm
    kustomize
    kubectx     # fast context/namespace switching
    k9s         # terminal UI for kubernetes (highly recommended)
    argocd
    flux
    # stern     # multi-pod log tailing (optional)
    # krew      # plugin manager for kubectl (optional)

    # Infrastructure as Code
    terraform
    tflint    # linter (optional but very useful)
    tfsec     # security scanner (optional)
    # terragrunt (optional, if you use it)

    # ─── Database CLIs & utils ───
    postgresql        # includes psql, pg_dump, pg_restore, etc.
    mongosh           # modern MongoDB shell (replaces mongo shell)
    mongodb-tools     # mongoimport, mongodump, bsondump, etc.
    mariadb.client           # mysql client + mysqldump
    redis             # redis-cli
    sqlite            # sqlite3 CLI

    # ─── Secrets management ───
    sops
    age           # modern & simple encryption tool (most common with sops)
    # rage        # rust implementation of age (alternative, optional)
    ssh-to-age    # convert ssh pubkey → age pubkey (very useful)
    keycloak

    # CI/CD & GitOps
    gh                    # GitHub CLI
    act                   # local GitHub Actions runner

    # Networking & debugging
    tcpdump
    nmap
    netcat
    httpie                # modern curl
    jq yq                 # json/yaml processing
    mitmproxy             # HTTP/HTTPS proxy
    ngrok                 # public tunnels

    # Monitoring & observability
    #grafana               # local dashboard
    #prometheus
    #loki                  # log aggregation (optional)

    # Container & registry
    skopeo                # inspect/copy images
    dive                  # explore container layers
    reg                   # simple registry client

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
