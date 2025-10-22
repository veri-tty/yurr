{
  config,
  lib,
  pkgs,
  ...
}: {
  config = {
    ## Setting up portals
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      configPackages = [pkgs.xdg-desktop-portal-gtk];
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
    ## Needed so that the user dirs get exported as env vars
    environment.systemPackages = [pkgs.xdg-user-dirs];

    ## Enabling XDG
    home-manager.users.ml = {
      xdg.enable = true;
      #configFile."mimeapps.list".force = true; # Removes mimieapps.list when rebuilding system to prevent error, probably gonna be fixed at some point, but in here for now

      ## Setting custom cacheHome
      xdg.cacheHome = "/home/ml/.local/cache";

      ## Enable XDG mime type handling
      xdg.mime.enable = true;
      xdg.mimeApps.enable = true;

      ## Enable XDG user directories
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
        documents = "/home/ml/repos";
        download = "/home/ml/dl";
        pictures = "/home/ml/media";
	
        ## Unused directories
        desktop = null;
        music = null;
        publicShare = null;
        templates = null;
        videos = null;
      };
    };
  };
}
