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
    ## Sec for VM
networking.firewall.extraCommands = ''
    # Allow responses to host-initiated connections (SSH to VM)
    iptables -I INPUT 1 -i vboxnet0 -m conntrack --ctstate 
  ESTABLISHED,RELATED -j ACCEPT
    # Block VM from initiating any connection to host
    iptables -I INPUT 2 -i vboxnet0 -j DROP
    
    # Same for forwarded traffic (Docker, etc)
    iptables -I FORWARD 1 -i vboxnet0 -m conntrack --ctstate 
  ESTABLISHED,RELATED -j ACCEPT
    iptables -I FORWARD 2 -i vboxnet0 -j DROP
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -i vboxnet0 -m conntrack --ctstate 
  ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -i vboxnet0 -j DROP 2>/dev/null || true
    iptables -D FORWARD -i vboxnet0 -m conntrack --ctstate 
  ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    iptables -D FORWARD -i vboxnet0 -j DROP 2>/dev/null || true
  '';

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
