# Headless X11 + x11vnc for remote GUI access
# Connect from your local machine to run virt-manager, VMs, etc.

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.sandbox;
in
{
  config = lib.mkIf cfg.enable {
    # ============================================
    # X11 + OPENBOX
    # ============================================

    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
    };

    # ============================================
    # PACKAGES
    # ============================================

    environment.systemPackages = with pkgs; [
      # X11 + VNC
      tigervnc
      openbox
      xterm
      dmenu
      feh

      # Virtualization
      virt-manager
      virt-viewer
      spice-gtk
      qemu
      OVMF
      swtpm

      # Browser
      librewolf
    ];

    # ============================================
    # VIRTUALIZATION (QEMU/KVM + libvirt)
    # ============================================

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    # Add user to libvirtd group
    users.users.ml.extraGroups = [ "libvirtd" ];

    # Enable dconf for virt-manager settings
    programs.dconf.enable = true;

    # ============================================
    # TIGERVNC SERVER (runs X11 headless)
    # ============================================

    systemd.services.vncserver = {
      description = "TigerVNC Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = [ pkgs.xorg.xauth pkgs.openbox pkgs.xterm pkgs.dbus pkgs.coreutils pkgs.util-linux ];

      environment = {
        HOME = "/home/ml";
        DISPLAY = ":5";
      };

      serviceConfig = {
        Type = "simple";
        User = "ml";
        ExecStart = "${pkgs.tigervnc}/bin/Xvnc :5 -geometry 1920x1080 -depth 24 -rfbauth /home/ml/.vnc/passwd -rfbport 5905 -SecurityTypes VncAuth";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    # Window manager service
    systemd.services.openbox-session = {
      description = "Openbox Window Manager";
      wantedBy = [ "multi-user.target" ];
      after = [ "vncserver.service" ];
      requires = [ "vncserver.service" ];

      path = [ pkgs.openbox pkgs.xterm ];

      environment = {
        DISPLAY = ":5";
        HOME = "/home/ml";
      };

      serviceConfig = {
        Type = "simple";
        User = "ml";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
        ExecStart = "${pkgs.openbox}/bin/openbox";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    # VNC password setup
    system.activationScripts.vncSetup = ''
      mkdir -p /home/ml/.vnc
      echo -n "password" | ${pkgs.tigervnc}/bin/vncpasswd -f > /home/ml/.vnc/passwd
      chmod 600 /home/ml/.vnc/passwd
      chown -R ml:users /home/ml/.vnc
    '';

    # ============================================
    # FIREWALL
    # ============================================

    networking.firewall.allowedTCPPorts = [
      5905  # VNC :5
    ];
  };
}
