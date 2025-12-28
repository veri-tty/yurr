{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.desktop;
  barScript = pkgs.writeShellScript "sway-bar.sh" ''
    while true; do
      # Volume with icon
      vol=$(${pkgs.pamixer}/bin/pamixer --get-volume)
      muted=$(${pkgs.pamixer}/bin/pamixer --get-mute)
      if [ "$muted" = "true" ]; then
        vol_icon="󰝟"
      elif [ "$vol" -gt 50 ]; then
        vol_icon="󰕾"
      elif [ "$vol" -gt 0 ]; then
        vol_icon="󰖀"
      else
        vol_icon="󰕿"
      fi

      # Battery with icon
      bat=$(${pkgs.acpi}/bin/acpi -b 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP '\d+(?=%)' | head -1)
      charging=$(${pkgs.acpi}/bin/acpi -b 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c "Charging")
      if [ -z "$bat" ]; then
        bat_str=""
      elif [ "$charging" -gt 0 ]; then
        bat_str="󰂄 $bat%"
      elif [ "$bat" -gt 80 ]; then
        bat_str="󰁹 $bat%"
      elif [ "$bat" -gt 60 ]; then
        bat_str="󰂀 $bat%"
      elif [ "$bat" -gt 40 ]; then
        bat_str="󰁾 $bat%"
      elif [ "$bat" -gt 20 ]; then
        bat_str="󰁼 $bat%"
      else
        bat_str="󰁺 $bat%"
      fi

      # Network
      wifi=$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi | ${pkgs.gnugrep}/bin/grep '^yes' | cut -d: -f2)
      if [ -n "$wifi" ]; then
        net="󰖩 $wifi"
      else
        net="󰖪"
      fi

      # Date/time
      datetime=$(${pkgs.coreutils}/bin/date +'%a %d %b  %H:%M')

      # Build output
      if [ -n "$bat_str" ]; then
        echo "$net   $vol_icon $vol%   $bat_str   $datetime"
      else
        echo "$net   $vol_icon $vol%   $datetime"
      fi
      sleep 2
    done
  '';
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;
      settings.animation = "doom";
    };

    programs.light.enable = true;
    services.gnome.gnome-keyring.enable = true;
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      android-tools
      # Sway utilities
      grim slurp wl-clipboard wmenu foot swaylock swaybg pamixer acpi brightnessctl
      # Apps
      signal-desktop mpv waveterm vlc qbittorrent waydroid feather
      bitwarden-desktop
      tor-browser electrum wasistlos spotdl spotify nicotine-plus
      betaflight-configurator
      # Browsers
      google-chrome chromium
      # Networking
      eddie yggstack wireguard-tools bluez networkmanagerapplet
      # Notes
      affine

    ];

    networking.hosts = {
      "10.129.45.239" = [ "thetoppers.htb" ];
      "10.129.2.156" = [ "gavel.htb" ];
      "10.129.95.234" = [ "unika.htb" ];
    };

    home-manager.users.ml = { config, ... }: {
      imports = [ inputs.zen-browser.homeModules.beta ];

      home.packages = [ pkgs.polkit_gnome ];

      # GTK dark theme configuration
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
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
        Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.qutebrowser.enable = true;

      xdg.mimeApps = let
        associations = builtins.listToAttrs (map (name: {
          inherit name;
          value = config.programs.zen-browser.package.meta.desktopFileName;
        }) [
          "application/x-extension-shtml" "application/x-extension-xhtml"
          "application/x-extension-html" "application/x-extension-xht"
          "application/x-extension-htm" "x-scheme-handler/unknown"
          "x-scheme-handler/mailto" "x-scheme-handler/chrome"
          "x-scheme-handler/about" "x-scheme-handler/https"
          "x-scheme-handler/http" "application/xhtml+xml"
          "application/json" "text/plain" "text/html"
        ]);
      in {
        associations.added = associations;
        defaultApplications = associations;
      };

      programs.firefox = {
        enable = true;
        package = pkgs.librewolf;
        languagePacks = [ "en-US" "de-DE" ];
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          ExtensionSettings = {
            "foxyproxy@eric.h.jung" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
              installation_mode = "force_installed";
            };
            "addon@karakeep.app" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/karakeep/latest.xpi";
              installation_mode = "force_installed";
            };
            "CanvasBlocker@kkapsner.de" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/canvasblocker/latest.xpi";
              installation_mode = "force_installed";
            };
          };
          Preferences = {
            "webgl.disabled" = { Value = false; Status = "locked"; };
            "privacy.resistFingerprinting" = { Value = true; Status = "locked"; };
            "privacy.trackingprotection.enabled" = { Value = true; Status = "locked"; };
            "network.cookie.lifetimePolicy" = { Value = 2; Status = "locked"; };
            "privacy.clearOnShutdown.cookies" = { Value = true; Status = "locked"; };
            "privacy.clearOnShutdown.history" = { Value = true; Status = "locked"; };
            "browser.shell.checkDefaultBrowser" = { Value = false; Status = "locked"; };
          };
        };
      };

      programs.zen-browser = {
        enable = true;
        policies = let
          mkLockedAttrs = builtins.mapAttrs (_: value: { Value = value; Status = "locked"; });
          mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
          mkExtensionEntry = { id, pinned ? false }: let
            base = { install_url = mkPluginUrl id; installation_mode = "force_installed"; };
          in if pinned then base // { default_area = "navbar"; } else base;
          mkExtensionSettings = builtins.mapAttrs (_: entry:
            if builtins.isAttrs entry then entry else mkExtensionEntry { id = entry; });
        in {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = { Value = true; Locked = true; Cryptomining = true; Fingerprinting = true; };
          ExtensionSettings = mkExtensionSettings {
            "uBlock0@raymondhill.net" = "ublock-origin";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = mkExtensionEntry { id = "bitwarden-password-manager"; pinned = true; };
            "addon@karakeep.app" = mkExtensionEntry { id = "karakeep"; pinned = true; };
          };
          Preferences = mkLockedAttrs {
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.warnOnClose" = false;
            "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
            "browser.gesture.swipe.left" = "";
            "browser.gesture.swipe.right" = "";
            "browser.tabs.hoverPreview.enabled" = true;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.topsites.contile.enabled" = false;
            "privacy.resistFingerprinting" = true;
            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 5;
            "dom.battery.enabled" = false;
            "gfx.webrender.all" = true;
            "network.http.http3.enabled" = true;
          };
        };
        profiles.default = {
          id = 0;
          settings = {
            "zen.welcome-screen.seen" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "font.name.monospace.x-western" = "IBM Plex Mono";
            "font.name.sans-serif.x-western" = "IBM Plex Sans";
            "font.name.serif.x-western" = "IBM Plex Serif";
          };
          userChrome = ''
            #back-button, #forward-button, #reload-button, #stop-button,
            #home-button, #library-button, #fxa-toolbar-menu-button { display: none !important; }
            * { font-family: "IBM Plex Sans" !important; }
          '';
        };
      };

      wayland.windowManager.sway = {
        enable = true;
        config = rec {
          modifier = "Mod4";
          terminal = "kitty";
          menu = "wmenu-run";
          left = "h"; down = "j"; up = "k"; right = "l";

          input = {
            "*" = { xkb_layout = "de"; xkb_options = "caps:escape"; };
            "type:touchpad" = { dwt = "true"; tap = "enabled"; natural_scroll = "enabled"; };
            "type:keyboard" = { xkb_layout = "de"; xkb_options = "caps:escape"; };
          };

          window = { border = 2; titlebar = false; };
          gaps.inner = 8;
          gaps.outer = 4;
          fonts = { names = [ "IBM Plex Mono" ]; size = 11.0; };
          floating.modifier = "${modifier}";

          colors = {
            focused = {
              border = "#88c0d0";
              background = "#2e3440";
              text = "#eceff4";
              indicator = "#b48ead";
              childBorder = "#88c0d0";
            };
            focusedInactive = {
              border = "#4c566a";
              background = "#2e3440";
              text = "#d8dee9";
              indicator = "#4c566a";
              childBorder = "#4c566a";
            };
            unfocused = {
              border = "#3b4252";
              background = "#2e3440";
              text = "#4c566a";
              indicator = "#3b4252";
              childBorder = "#3b4252";
            };
            urgent = {
              border = "#bf616a";
              background = "#bf616a";
              text = "#eceff4";
              indicator = "#bf616a";
              childBorder = "#bf616a";
            };
          };

          keybindings = let lockscreen = "${config.home.homeDirectory}/media/wall/heyapple.jpg"; in lib.mkOptionDefault {
            "${modifier}+q" = "kill";
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+d" = "exec ${menu}";
            "${modifier}+Delete" = "exec swaylock -i ${lockscreen}";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+e" = "exec swaynag -t warning -m 'nahh bru dont leave' -B 'yurr' 'swaymsg exit'";
            "${modifier}+${left}" = "focus left"; "${modifier}+${down}" = "focus down";
            "${modifier}+${up}" = "focus up"; "${modifier}+${right}" = "focus right";
            "${modifier}+Left" = "focus left"; "${modifier}+Down" = "focus down";
            "${modifier}+Up" = "focus up"; "${modifier}+Right" = "focus right";
            "${modifier}+Shift+${left}" = "move left"; "${modifier}+Shift+${down}" = "move down";
            "${modifier}+Shift+${up}" = "move up"; "${modifier}+Shift+${right}" = "move right";
            "${modifier}+Shift+Left" = "move left"; "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Up" = "move up"; "${modifier}+Shift+Right" = "move right";
            "${modifier}+1" = "workspace number 1"; "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3"; "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5"; "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7"; "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9"; "${modifier}+0" = "workspace number 10";
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
            "${modifier}+b" = "splith"; "${modifier}+v" = "splitv";
            "${modifier}+s" = "layout stacking"; "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split"; "${modifier}+f" = "fullscreen";
            "${modifier}+Shift+space" = "floating toggle"; "${modifier}+space" = "focus mode_toggle";
            "${modifier}+a" = "focus parent"; "${modifier}+Shift+minus" = "move scratchpad";
            "${modifier}+minus" = "scratchpad show"; "${modifier}+r" = "mode resize";
            "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
            "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
            "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
            "Print" = "exec grim";
          };

          modes.resize = {
            "${left}" = "resize shrink width 10px"; "${down}" = "resize grow height 10px";
            "${up}" = "resize shrink height 10px"; "${right}" = "resize grow width 10px";
            "Left" = "resize shrink width 10px"; "Down" = "resize grow height 10px";
            "Up" = "resize shrink height 10px"; "Right" = "resize grow width 10px";
            "Return" = "mode default"; "Escape" = "mode default";
          };

          bars = [{
            position = "top";
            statusCommand = "${barScript}";
            fonts = { names = [ "JetBrainsMono Nerd Font" ]; size = 10.0; };
            colors = {
              background = "#2e3440";
              statusline = "#d8dee9";
              separator = "#4c566a";
              focusedWorkspace = { border = "#88c0d0"; background = "#88c0d0"; text = "#2e3440"; };
              activeWorkspace = { border = "#4c566a"; background = "#4c566a"; text = "#d8dee9"; };
              inactiveWorkspace = { border = "#2e3440"; background = "#2e3440"; text = "#4c566a"; };
              urgentWorkspace = { border = "#bf616a"; background = "#bf616a"; text = "#eceff4"; };
            };
          }];
        };
        checkConfig = false;
      };
    };
  })

    (lib.mkIf cfg.gaming {
      programs.steam.enable = true;
      environment.systemPackages = with pkgs; [
        wineWowPackages.waylandFull
      ];
    })
  ];
}
