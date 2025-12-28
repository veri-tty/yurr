{ config, lib, pkgs, ... }:
let
  cfg = config.modules.server;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.cifs-utils
      pkgs.docker-compose
      pkgs.pcmanfm  # file manager for openbox
      pkgs.xterm
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
    ];
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "gtk";
    };
    services.xrdp = {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "openbox-session";
    };
    services.xserver.windowManager.openbox.enable = true;
    services.xserver.desktopManager.lxqt.enable = true;
   # For mount.cifs, required unless domain name resolution is not needed.
    fileSystems."/mnt/box" = {
      device = "//u455112.your-storagebox.de/backup";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/.smbcredentials"];
    };

    # Virtualization (merged from virt.nix)
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ "ml" ];
  };
}
