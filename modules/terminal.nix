{
  config,
  lib,
  pkgs,
  ...
}: {
    environment.systemPackages = [
      pkgs.kitty
    ];
    ## Enable ZSH system wide
    programs.zsh.enable = true;

    ## add zsh to `/etc/shells'
    environment.shells = with pkgs; [zsh];

    ## Needed for completion
    environment.pathsToLink = ["/share/zsh"];

    ## Enable zsh for current user
    users.users.ml.shell = pkgs.zsh;

    # Add Zoxide
    home-manager.users.ml = {
      programs.kitty = {
        enable = true;
        font = {
          name = "FiraCode Nerd Font";
          size = 12;
        };
        settings = {
          confirm_os_window_close = 0;
        };
      };
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.bat = {
        enable = true;
        config = {
          pager = "less -R"; # Don't auto-exit if one screen
        };
      };
      ## ZSH configuration
      programs.zsh = {
        enable = true;
        shellAliases = {
          nrs = "sudo nixos-rebuild switch --flake /home/ml/repos/flake#";
          cat = "bat";
        };

        ## Enable some QOL features
        autosuggestion.enable = true;
        enableCompletion = true;
        historySubstringSearch.enable = true;
        syntaxHighlighting = {
          enable = true;
          highlighters = ["main" "brackets" "pattern" "regexp" "line"];
        };

        ## Setting config dir
        ## Path is relative to $HOME, so we can't use `xdg.configHome' here.
        dotDir = ".config/zsh";

        ## History
        history = {
          path = "/home/ml/.cache/zsh/zsh_history";
        };

        ## Save completion dump into $XDG_CACHE_HOME
        completionInit = ''
          autoload -U compinit
          compinit -d ".zcompdump"
        '';
      };
    };
}
