{ lib, ... }:
with lib;
{
  options.modules = {
    desktop = {
      enable = mkEnableOption "desktop environment (sway, apps, browser)";
      gaming = mkEnableOption "gaming support (steam, wine)";
    };

    dev = {
      enable = mkEnableOption "development tools";
    };

    pentest = {
      enable = mkEnableOption "penetration testing tools";
    };

    server = {
      enable = mkEnableOption "server services (docker)";
    };

    editor = {
      neovim = mkEnableOption "nixvim configuration";
    };
  };
}
