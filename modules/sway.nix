{ config, pkgs, lib, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  users.users.ml.extraGroups = [ "video" ];
  programs.light.enable = true;
  environment.systemPackages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
  ];
  services.gnome.gnome-keyring.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  home-manager.users.ml = {
    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty"; 
	keybindings = {
	  "${modifier}+q" = "kill";
	  "${modifier}+Return" = "exec ${terminal}";
	  "${modifier}+w" = "exec zen-browser";
	};
      }; 
      checkConfig = true;
    };
  };
}
