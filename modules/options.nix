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

    claude-sandbox = {
      enable = mkEnableOption "isolated Claude Code container with Tor-only pentest access";
      whonixWsIp = mkOption {
        type = types.str;
        default = "10.152.152.11";
        description = "IP address of Whonix Workstation on internal network";
      };
      externalInterface = mkOption {
        type = types.str;
        default = "eth0";
        description = "External network interface for NAT (e.g., eth0, enp0s3)";
      };
    };

    editor = {
      neovim = mkEnableOption "nixvim configuration";
    };

    sandbox = {
      enable = mkEnableOption "headless Sway + wayvnc with QEMU/libvirt stack";
    };
  };
}
