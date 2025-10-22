{ inputs, config, pkgs, ... }:
{
  home-manager.users.ml = {
    imports = [
      inputs.zen-browser.homeModules.beta
    ];

    xdg.mimeApps = let
      associations = builtins.listToAttrs (map (name: {
          inherit name;
          value = let
            zen-browser = config.home-manager.users.ml.programs.zen-browser.package;
          in
            zen-browser.meta.desktopFileName;
        }) [
          "application/x-extension-shtml"
          "application/x-extension-xhtml"
          "application/x-extension-html"
          "application/x-extension-xht"
          "application/x-extension-htm"
          "x-scheme-handler/unknown"
          "x-scheme-handler/mailto"
          "x-scheme-handler/chrome"
          "x-scheme-handler/about"
          "x-scheme-handler/https"
          "x-scheme-handler/http"
          "application/xhtml+xml"
          "application/json"
          "text/plain"
          "text/html"
        ]);
    in {
      associations.added = associations;
      defaultApplications = associations;
    };

    programs.zen-browser = {
      enable = true;

      policies = let
        mkLockedAttrs = builtins.mapAttrs (_: value: {
          Value = value;
          Status = "locked";
        });

        mkPluginUrl = id: "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";

        mkExtensionEntry = {
          id,
          pinned ? false,
        }: let
          base = {
            install_url = mkPluginUrl id;
            installation_mode = "force_installed";
          };
        in
          if pinned
          then base // {default_area = "navbar";}
          else base;

        mkExtensionSettings = builtins.mapAttrs (_: entry:
          if builtins.isAttrs entry
          then entry
          else mkExtensionEntry {id = entry;});
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
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        ExtensionSettings = mkExtensionSettings {
          "uBlock0@raymondhill.net" = "ublock-origin";
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = mkExtensionEntry {
            id = "bitwarden-password-manager";
            pinned = true;
          };
          "addon@karakeep.app" = mkExtensionEntry {
            id = "karakeep";
            pinned = true;
          };
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
          "font.name.monospace.x-western" = "FiraCode Nerd Font";
          "font.name.sans-serif.x-western" = "FiraCode Nerd Font";
          "font.name.serif.x-western" = "FiraCode Nerd Font";
        };

        userChrome = ''
          /* Hide navigation buttons - keep only application menu and pinned extensions */
          #back-button,
          #forward-button,
          #reload-button,
          #stop-button,
          #home-button,
          #library-button,
          #fxa-toolbar-menu-button {
            display: none !important;
          }

          /* Set FiraCode as font */
          * {
            font-family: "FiraCode Nerd Font" !important;
          }
        '';
      };
    };
  };
}
