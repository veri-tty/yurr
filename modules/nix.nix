{ pkgs, config, ... }:
{
  config = {
    nix = {
      ## Enabling flakes
      extraOptions = ''
        experimental-features = nix-command flakes
        warn-dirty = false
      '';
      ## Store optimization
      optimise.automatic = true;

      ## Automatic garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    ## Timezone and locales
    ## I don't travel
    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";

    home-manager.backupFileExtension = "delme";
    ## Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    ## Setting correct application settings if we're running wayland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    ## Global packages
    ## Packages should be managed with home-manager whereever
    ## possible. Only use a set of barebones applications here.
    environment.systemPackages = with pkgs; [git unzip wget curl ripgrep];

    ## Home manager settings
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    ## Setting the `stateVersion' for both home-manager and system.
    home-manager.users.ml.home.stateVersion = "24.11";
    ## Setting state version for system
    system.stateVersion = "24.11";
  };
}
