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

      serviceConfig = {
        Type = "forking";
        User = "ml";
        ExecStartPre = "${pkgs.bash}/bin/bash -c 'mkdir -p ~/.vnc && echo -n \"password\" | ${pkgs.tigervnc}/bin/vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd'";
        ExecStart = "${pkgs.tigervnc}/bin/vncserver :1 -geometry 1920x1080 -depth 24 -localhost no";
        ExecStop = "${pkgs.tigervnc}/bin/vncserver -kill :1";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    # ============================================
    # OPENBOX CONFIG
    # ============================================

    # Xstartup for VNC sessions
    environment.etc."X11/xinit/xinitrc".text = ''
      #!/bin/sh
      xterm &
      exec openbox
    '';

    # ============================================
    # FIREWALL
    # ============================================

    networking.firewall.allowedTCPPorts = [
      5901  # VNC :1
    ];
  };
}
