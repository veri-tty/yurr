{ config, pkgs, lib, ... }:
let
  barScript = pkgs.writeShellScript "sway-bar.sh" ''
    while true
    do
      volume=$(${pkgs.pamixer}/bin/pamixer --get-volume)
      date=$(${pkgs.coreutils}/bin/date +'%H:%M')
      battery=$(${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -oP '\d+(?=%)')
      echo "vol:$volume | bat:$battery | $date "
      sleep 1
    done
  '';
in
{
    #services.greetd = {
     #      enable = true;
     #  settings = {
     #    default_session = {
     #      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
     #      user = "greeter";
     #    };
     #  };
     #};
  services.displayManager.ly = {
    enable = true;
    settings = { animation = "doom"; };
  };
  users.users.ml.extraGroups = [ "video" ];
  programs.light.enable = true;
  environment.systemPackages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    wmenu
    foot # terminal
    swaylock # screen locker
    swaybg # background manager
    pamixer # volume control
    acpi # battery info
    brightnessctl # brightness control
  ];
  services.gnome.gnome-keyring.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  home-manager.users.ml = { config, ... }: {
  home.packages = [
    pkgs.polkit_gnome
  ];

  # Disable notification daemons
  services.mako.enable = false;
  services.dunst.enable = false;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "Polkit GNOME Authentication Agent";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
    wayland.windowManager.sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty";
        menu = "wmenu-run";

        # Vim-style direction keys
        left = "h";
        down = "j";
        up = "k";
        right = "l";

        # Input configuration
        input = {
          "*" = {
            xkb_layout = "de";
            xkb_options = "caps:escape";
          };
          "type:touchpad" = {
            dwt = "true";
            tap = "enabled";
            natural_scroll = "enabled";
          };
          "type:keyboard" = {
            xkb_layout = "de";
            xkb_options = "caps:escape";
          };
        };

        # Window appearance
        window = {
          border = 2;
          titlebar = false;
        };
        fonts = {
          names = [ "FiraCode" ];
          size = 12.0;
        };

        # Floating modifier
        floating.modifier = "${modifier}";

        # Keybindings
        keybindings = let
          lockscreen = "${config.home.homeDirectory}/media/wall/heyapple.jpg";
        in lib.mkOptionDefault {
          # Basics
          "${modifier}+q" = "kill";
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+d" = "exec ${menu}";
          "${modifier}+Delete" = "exec swaylock -i ${lockscreen}";

          # Reload and exit
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" = "exec swaynag -t warning -m 'nahh bru dont leave' -B 'yurr' 'swaymsg exit'";

          # Moving around with vim keys
          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";

          # Arrow keys
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # Move windows with vim keys
          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";

          # Move windows with arrow keys
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Workspaces
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";

          # Move to workspaces
          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          # Layout stuff
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+f" = "fullscreen";

          # Floating
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";

          # Scratchpad
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          # Resize mode
          "${modifier}+r" = "mode resize";

          # Utilities - Audio
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";

          # Utilities - Brightness
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
          "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

          # Screenshot
          "Print" = "exec grim";
        };

        # Resize mode
        modes = {
          resize = {
            "${left}" = "resize shrink width 10px";
            "${down}" = "resize grow height 10px";
            "${up}" = "resize shrink height 10px";
            "${right}" = "resize grow width 10px";

            "Left" = "resize shrink width 10px";
            "Down" = "resize grow height 10px";
            "Up" = "resize shrink height 10px";
            "Right" = "resize grow width 10px";

            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };

        # Bar configuration
        bars = [{
          position = "top";
          statusCommand = "${barScript}";
          fonts = {
            names = [ "FiraCode Nerd Font" ];
            size = 11.0;
          };

          colors = {
            statusline = "#ffffff";
            background = "#323232";
            inactiveWorkspace = {
              border = "#32323200";
              background = "#32323200";
              text = "#5c5c5c";
            };
          };
        }];
      };
      checkConfig = false;
      extraConfig =
      ''
        output * bg ${config.home.homeDirectory}/media/wall/hassowo.png stretch
      '';
    };
  };
}

