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
  environment.systemPackages = with pkgs; [ kitty xdg-user-dirs ];
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  environment.pathsToLink = [ "/share/zsh" ];
  users.users.ml.shell = pkgs.zsh;

  home-manager.users.ml = { config, ... }: {
    programs.kitty = {
      enable = true;
      font = {
        name = "FiraCode Nerd Font";
        size = 12;
      };
      settings.confirm_os_window_close = 0;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      config.pager = "less -R";
    };

    programs.zsh = {
      enable = true;
      shellAliases = {
        pic = "grim -g '$(slurp -w 0)'";
        nrs = "sudo nixos-rebuild switch --flake /home/ml/repos/flake#${hostname}";
        ynrs = "nixos-rebuild switch --flake .#yalt --target-host root@65.109.123.217 --use-remote-sudo";
        cat = "bat -p";
      };
      autosuggestion.enable = true;
      enableCompletion = true;
      historySubstringSearch.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "pattern" "regexp" "line" ];
      };
      dotDir = "${config.xdg.configHome}/zsh";
      history.path = "/home/ml/.cache/zsh/zsh_history";
      completionInit = ''
        autoload -U compinit
        compinit -d "$HOME/.cache/zsh/.zcompdump"
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
