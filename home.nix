{ config, pkgs, lib, ... }:

{
  # ────────────────────────────────────────────────
  #  Basic user & state settings
  # ────────────────────────────────────────────────
  home.username      = "daveli";
  home.homeDirectory = "/Users/daveli";
  home.stateVersion  = "25.11";

  xdg.enable = true;  # enables XDG directories — recommended on macOS

  # ────────────────────────────────────────────────
  #  Packages – grouped by category
  # ────────────────────────────────────────────────
  home.packages = with pkgs; [
    # ─── Core CLI & productivity ───
    # neovim                 # main editor
    ripgrep                # fast grep alternative (rg)
    # fd                     # fast find alternative
    bat                    # cat with syntax highlighting
    eza                    # modern ls replacement
    fzf                    # fuzzy finder
    git                    # version control

    just                   # simple task runner (Justfile)
    httpie                 # modern curl / http client
    jq                     # json processor
    yq                     # yaml processor

    # ─── Nix & linting tools ───
    nixfmt-rfc-style       # official Nix formatter (was nixfmt-rfc-style)
    statix                 # linter for Nix code
    deadnix                # find dead code in Nix files
    # alejandra              # alternative Nix formatter

    # ─── Git & hooks ───
    lefthook               # fast git hooks manager

    # ─── Shell & scripting ───
    shellcheck             # linter for shell scripts
    shfmt                  # shell script formatter

    # ─── Cloud & infra CLIs ───
    awscli2                # AWS command line interface
    azure-cli              # Microsoft Azure CLI

    kubectl                # Kubernetes CLI
    kubernetes-helm        # Helm – Kubernetes package manager (binary version)
    kustomize              # Kubernetes configuration management
    kubectx                # fast kubectl context/namespace switching
    k9s                    # terminal UI for Kubernetes
    argocd                 # Argo CD CLI (GitOps)
    kubeseal                # Sealed Secrets CLI – encrypt K8s secrets for git
    # flux                   # Flux CD CLI (GitOps)

    terraform              # infrastructure as code
    tflint                 # Terraform linter
    tfsec                  # Terraform security scanner
    checkov                # IaC security & compliance scanner
    hadolint               # Dockerfile linter

    # ─── Databases ───
    postgresql             # PostgreSQL client (psql, pg_dump, etc.)
    pgcli                  # nicer interactive PostgreSQL client
    mongosh                # modern MongoDB shell
    mongodb-tools          # mongoimport, mongodump, etc.
    vi-mongo               # TUI for MongoDB (data viz & quick manipulation)
    mariadb.client         # MySQL/MariaDB client + mysqldump
    redis                  # Redis CLI
    sqlite                 # SQLite CLI (sqlite3)

    # ─── Secrets & security ───
    sops                   # secrets management (editor + encrypt/decrypt)
    age                    # modern age encryption (used with sops)
    ssh-to-age             # convert SSH pubkey → age pubkey
    # vault                  # HashiCorp Vault CLI
    keycloak               # identity & access management (OIDC)

    # ─── CI/CD & Git platforms ───
    gh                     # GitHub CLI
    act                    # local GitHub Actions runner
    k6                     # load testing (HTTP, gRPC, etc.)

    # ─── Networking & debugging ───
    cloudflared            # Cloudflare Tunnel daemon (zero-trust access)
    tcpdump                # network packet analyzer
    nmap                   # network scanner
    netcat                 # networking utility
    sshpass                # non-interactive SSH password auth
    mitmproxy              # HTTP/HTTPS proxy & inspector
    ngrok                  # secure public tunnels

    # ─── Container tools ───
    skopeo                 # inspect / copy container images
    dive                   # explore container image layers
    reg                    # simple container registry client

    # ─── Media ───
    ffmpeg                 # audio/video encoding, decoding, streaming

    # ─── Editors (CLI on PATH for vscodesync) ───
    vscode                 # VS Code – provides `code` CLI for cursor-to-vscode-sync

    # ─── Runtime manager ───
    mise                   # polyglot runtime manager (node, python, etc.)

    # ─── Languages ───
    python312              # Python 3.12 with pip
    nodejs_22              # Node.js 22 (LTS)
    go                     # Go toolchain
    jdk17                  # OpenJDK 17 (Java)
    maven                  # Apache Maven build tool
  ];

  # ────────────────────────────────────────────────
  #  Programs & integrations
  # ────────────────────────────────────────────────
  programs = {
    # Let Home Manager manage itself + some helpers
    home-manager.enable = true;

    # Git basic setup
    git = {
      enable = true;
      # Add userName, userEmail, delta, signing, etc. here later
    };

    # Zsh – shell configuration
    zsh = {
      enable = true;

      # Explicitly lock in current legacy behavior to silence warning
      dotDir = config.home.homeDirectory;  # ← keeps .zshrc in ~ (current behavior)

      enableCompletion      = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        hms     = "home-manager switch --flake ~/.config/home-manager && source ~/.zshrc";
        hmgen   = "home-manager generations";
        hmr     = "home-manager generations | tail -n +4 | awk '{for(i=1;i<=NF;i++) if(\$i~/^[0-9]+\$/) {print \$i; exit}}' | xargs sh -c '[ \$# -gt 0 ] && exec home-manager remove-generations \"\$@\"' sh";
        hmpack  = "home-manager packages";
        hmreset = "nix-collect-garbage -d";

        skillsync   = "~/.config/home-manager/agents-skills/scripts/apply-agents-skills.sh --prune && ~/.config/home-manager/agents-skills/scripts/validate-skills.sh --user";
        rulesync   = "~/.config/home-manager/rules/apply-agents-rules.sh";

        cursorexport = "~/.config/home-manager/cursor/cursor-profile-export.sh";
        cursorimport = "~/.config/home-manager/cursor/cursor-profile-import.sh";
        vscodesync   = "~/.config/home-manager/cursor/cursor-to-vscode-sync.sh";
      };

      initContent = ''
        # Source hand-managed custom zshrc (keep manual edits here)
        if [ -f ~/.zshrc.custom ]; then
          source ~/.zshrc.custom
        fi
      '';
    };

    # Direnv – auto-load project environments
    direnv = {
      enable = true;
      nix-direnv.enable = true;

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

  # ────────────────────────────────────────────────
  #  Optional – uncomment when ready
  # ────────────────────────────────────────────────
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  #   VISUAL = "nvim";
  #   MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  # };
}