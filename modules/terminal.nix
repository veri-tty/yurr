{
  config,
  lib,
  pkgs,
  ...
}:
let
  hostname = config.networking.hostName;
in
{
  environment.systemPackages = with pkgs; [
    kitty
    xdg-user-dirs
    # cool cli tools
    fastfetch        # system info, way cooler than neofetch
    cmatrix          # the matrix rain
    pipes            # pipe screensaver
    cbonsai          # grow a bonsai tree
    asciiquarium     # aquarium in terminal
    lolcat           # rainbow everything
    figlet           # big ascii text
    toilet           # even fancier ascii text
    sl               # steam locomotive (for mistyping ls)
    cowsay           # cow says things
    fortune          # random quotes
    btop             # fancy system monitor
    glow             # markdown in terminal
    fzf              # fuzzy finder
    eza              # better ls with icons
    ripgrep          # better grep
    fd               # better find
    delta            # better git diff
    duf              # better df
    ncdu             # disk usage analyzer
    tldr             # simplified man pages
    procs            # better ps
    hyperfine        # benchmarking
    tokei            # code stats
  ];
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [ "/share/zsh" ];
  users.users.ml.shell = pkgs.zsh;

  home-manager.users.ml = { config, ... }: {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        confirm_os_window_close = 0;
        # cyberpunk/hacker color scheme
        background = "#0a0a0f";
        foreground = "#00ff9c";
        cursor = "#00ff9c";
        cursor_text_color = "#0a0a0f";
        selection_background = "#1a4a3a";
        selection_foreground = "#00ff9c";
        # black
        color0 = "#0a0a0f";
        color8 = "#1a1a2e";
        # red
        color1 = "#ff0055";
        color9 = "#ff3377";
        # green
        color2 = "#00ff9c";
        color10 = "#33ffb0";
        # yellow
        color3 = "#f0e800";
        color11 = "#f5f066";
        # blue
        color4 = "#0088ff";
        color12 = "#33a3ff";
        # magenta
        color5 = "#ff00ff";
        color13 = "#ff55ff";
        # cyan
        color6 = "#00e5ff";
        color14 = "#66edff";
        # white
        color7 = "#d0d0d0";
        color15 = "#ffffff";
        # terminal effects
        background_opacity = "0.92";
        window_padding_width = 10;
        enable_audio_bell = false;
        visual_bell_duration = "0.1";
        visual_bell_color = "#ff0055";
        cursor_shape = "beam";
        cursor_blink_interval = "0.5";
        scrollback_lines = 10000;
        url_color = "#0088ff";
        url_style = "curly";
      };
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = "$hostname$directory$git_branch$git_status$character";
        hostname = {
          ssh_only = false;
          style = "bold green";
          format = "[$hostname]($style) ";
        };
        directory = {
          style = "bold cyan";
          truncation_length = 3;
          truncation_symbol = "…/";
        };
        git_branch = {
          symbol = " ";
          style = "bold purple";
        };
        git_status = {
          style = "bold yellow";
        };
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
        cmd_duration = {
          min_time = 500;
          format = "[$duration](bold yellow)";
        };
        right_format = "$cmd_duration";
      };
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--color=bg+:#1a4a3a,bg:#0a0a0f,spinner:#00ff9c,hl:#ff0055"
        "--color=fg:#d0d0d0,header:#ff0055,info:#f0e800,pointer:#00ff9c"
        "--color=marker:#00ff9c,fg+:#00ff9c,prompt:#f0e800,hl+:#ff0055"
        "--border"
        "--height=40%"
      ];
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    programs.bat = {
      enable = true;
      config.pager = "less -R";
      config.theme = "base16";
    };

    programs.zsh = {
      enable = true;
      shellAliases = {
        pic = "grim -g '$(slurp -w 0)'";
        nrs = "sudo nixos-rebuild switch --flake /home/ml/repos/flake#${hostname}";
        ynrs = "nixos-rebuild switch --flake .#yalt --target-host root@65.109.123.217 --use-remote-sudo";
        cat = "bat -p";
        # cool aliases
        ls = "eza --icons";
        ll = "eza -la --icons --git";
        lt = "eza --tree --icons --level=2";
        tree = "eza --tree --icons";
        grep = "rg";
        find = "fd";
        df = "duf";
        ps = "procs";
        top = "btop";
        # fun stuff
        matrix = "cmatrix -b -u 3 -C green";
        rain = "cmatrix -b -u 2 -C cyan";
        hack = "cmatrix -b -u 1 -C red";
        bonsai = "cbonsai -l -i -w 5";
        fish = "asciiquarium";
        pipes = "pipes.sh -t 3 -c 2 -c 3 -c 4 -c 5";
        say = "cowsay | lolcat";
        fortune = "fortune | cowsay | lolcat";
        weather = "curl wttr.in";
        # useful shortcuts
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        cl = "clear";
        h = "history";
        pls = "sudo";
      };
      autosuggestion = {
        enable = true;
        highlight = "fg=#888888";
      };
      enableCompletion = true;
      historySubstringSearch.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "pattern" "cursor" "root" ];
      };
      dotDir = "${config.xdg.configHome}/zsh";
      history.path = "/home/ml/.cache/zsh/zsh_history";
      history.size = 50000;
      history.save = 50000;
      completionInit = ''
        autoload -U compinit
        compinit -d "$HOME/.cache/zsh/.zcompdump"
      '';
      initContent = ''
        # vim keybindings
        bindkey -v
        bindkey '^R' history-incremental-search-backward
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      '';
    };

    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      mouse = true;
      prefix = "C-a";
      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      extraConfig = ''
        # true colors
        set -ag terminal-overrides ",xterm-256color:RGB"

        # cyberpunk status bar
        set -g status-style "bg=#0a0a0f,fg=#00ff9c"
        set -g status-left "#[bg=#00ff9c,fg=#0a0a0f,bold]  #S #[bg=#0a0a0f,fg=#00ff9c]"
        set -g status-right "#[fg=#0a3a5a]#[bg=#0a3a5a,fg=#00e5ff]  %H:%M #[fg=#00ff9c]#[bg=#00ff9c,fg=#0a0a0f,bold] %d-%b "
        set -g status-left-length 30
        set -g status-right-length 50
        set -g status-justify centre

        # window status
        set -g window-status-format "#[fg=#1a4a3a]#[bg=#1a4a3a,fg=#d0d0d0] #I:#W #[fg=#1a4a3a,bg=#0a0a0f]"
        set -g window-status-current-format "#[fg=#0a3a5a]#[bg=#0a3a5a,fg=#00ff9c,bold] #I:#W #[fg=#0a3a5a,bg=#0a0a0f]"

        # pane borders
        set -g pane-border-style "fg=#1a4a3a"
        set -g pane-active-border-style "fg=#00ff9c"

        # message style
        set -g message-style "bg=#ff0055,fg=#0a0a0f,bold"

        # vim-like pane switching
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # split panes with | and -
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # new window in same directory
        bind c new-window -c "#{pane_current_path}"

        # reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
      '';
    };

    xdg = {
      enable = true;
      cacheHome = "/home/ml/.local/cache";
      mime.enable = true;
      mimeApps.enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        documents = "/home/ml/repos";
        download = "/home/ml/dl";
        pictures = "/home/ml/media";
        desktop = null;
        music = null;
        publicShare = null;
        templates = null;
        videos = null;
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    configPackages = [ pkgs.xdg-desktop-portal-gtk ];
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}
