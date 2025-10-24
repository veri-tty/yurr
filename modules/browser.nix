{ inputs, config, pkgs, ... }:
{
  home-manager.users.ml = {
    imports = [
      inputs.zen-browser.homeModules.beta
      inputs.schizofox.homeManagerModules.default
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
    programs.schizofox = {
      enable = true;

      theme = {
        colors = {
          background-darker = "181825";
          background = "1e1e2e";
          foreground = "cdd6f4";
        };

        font = "Lexend";

        extraUserChrome = ''
          body {
            color: red !important;
          }
        '';
      };

      search = {
        defaultSearchEngine = "Brave";
        removeEngines = ["Google" "Bing" "Amazon.com" "eBay" "Twitter" "Wikipedia"];
        searxUrl = "https://searx.be";
        searxQuery = "https://searx.be/search?q={searchTerms}&categories=general";
        addEngines = [
          {
            Name = "Etherscan";
            Description = "Checking balances";
            Alias = "!eth";
            Method = "GET";
            URLTemplate = "https://etherscan.io/search?f=0&q={searchTerms}";
          }
        ];
      };

      security = {
        sanitizeOnShutdown.enable = true;
        sandbox.enable = true;
        userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:106.0) Gecko/20100101 Firefox/106.0";
      };

      misc = {
        drmFix = true;
        disableWebgl = false;
        #startPageURL = "file://${builtins.readFile ./startpage.html}";
        contextMenu.enable = true;
      };

      extensions = {
        simplefox.enable = true;
        darkreader.enable = true;

        extraExtensions = {
          "webextension@metamask.io".install_url = "https://addons.mozilla.org/firefox/downloads/latest/ether-metamask/latest.xpi";
        };
      };

      bookmarks = [
        {
          Title = "Example";
          URL = "https://example.com";
          Favicon = "https://example.com/favicon.ico";
          Placement = "toolbar";
          Folder = "FolderName";
        }
      ];
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
