# Headless Sway + wayvnc for remote GUI access
# Connect from your local machine to run virt-manager, Whonix VMs, etc.

{ config, pkgs, lib, ... }:

let
  cfg = config.modules.sandbox;
in
{
  config = lib.mkIf cfg.enable {
    # ============================================
    # HEADLESS SWAY
    # ============================================

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # Required for wayland/sway
    hardware.graphics.enable = true;

    # If no GPU, use software rendering
    environment.variables = {
      WLR_RENDERER = "pixman";  # Software rendering fallback
      SWAY_CONFIG = "/etc/sway/config";
    };

    # ============================================
    # WAYVNC - VNC server for Wayland
    # ============================================

    environment.systemPackages = with pkgs; [
      wayvnc
      sway
      foot              # Terminal
      wofi              # Launcher
      wl-clipboard      # Clipboard support

      # Virtualization
      virt-manager      # VM management GUI
      virt-viewer       # VM display viewer
      spice-gtk         # SPICE client
      qemu              # QEMU emulator
      OVMF              # UEFI firmware for VMs
      swtpm             # TPM emulator

      # Browser
      librewolf         # Privacy-focused Firefox fork
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
    # AUTO-START SWAY + WAYVNC AS SYSTEM SERVICES
    # ============================================

    # System service that starts sway headless as ml user
    systemd.services.sway-headless = {
      description = "Headless Sway session";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-user-sessions.service" "dbus.service" ];
      wants = [ "dbus.service" ];

      path = [ pkgs.dbus ];

      environment = {
        WLR_BACKENDS = "headless";
        WLR_LIBINPUT_NO_DEVICES = "1";
        WLR_RENDERER = "pixman";
        XDG_RUNTIME_DIR = "/run/user/1000";
        WAYLAND_DISPLAY = "wayland-1";
      };

      serviceConfig = {
        Type = "simple";
        User = "ml";
        ExecStart = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway -c /etc/sway/config";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    # wayvnc service (starts after sway)
    systemd.services.wayvnc = {
      description = "wayvnc VNC server";
      wantedBy = [ "multi-user.target" ];
      after = [ "sway-headless.service" ];
      requires = [ "sway-headless.service" ];

      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };

      serviceConfig = {
        Type = "simple";
        User = "ml";
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
        ExecStart = "${pkgs.wayvnc}/bin/wayvnc 0.0.0.0 5900";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    # ============================================
    # FIREWALL
    # ============================================

    networking.firewall.allowedTCPPorts = [
      5900  # VNC
    ];

    # ============================================
    # SWAY CONFIG
    # ============================================

    # Create a basic sway config
    environment.etc."sway/config".text = ''
      # Headless sway config

      # Virtual output (headless)
      output HEADLESS-1 resolution 1920x1080 position 0,0

      # Set foot as default terminal
      set $term foot
      set $menu wofi --show drun

      # Mod key
      set $mod Mod4

      # Keybindings
      bindsym $mod+Return exec $term
      bindsym $mod+d exec $menu
      bindsym $mod+Shift+q kill
      bindsym $mod+Shift+c reload
      bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'

      # Focus
      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right

      # Move
      bindsym $mod+Shift+h move left
      bindsym $mod+Shift+j move down
      bindsym $mod+Shift+k move up
      bindsym $mod+Shift+l move right

      # Workspaces
      bindsym $mod+1 workspace 1
      bindsym $mod+2 workspace 2
      bindsym $mod+3 workspace 3
      bindsym $mod+Shift+1 move container to workspace 1
      bindsym $mod+Shift+2 move container to workspace 2
      bindsym $mod+Shift+3 move container to workspace 3

      # Resize mode
      mode "resize" {
        bindsym h resize shrink width 10px
        bindsym j resize grow height 10px
        bindsym k resize shrink height 10px
        bindsym l resize grow width 10px
        bindsym Escape mode "default"
      }
      bindsym $mod+r mode "resize"

      # Start with workspace 1
      exec swaymsg workspace 1
    '';
  };
}
