{ config, lib, pkgs, ... }:
let
  cfg = config.modules.dev;
in
{
  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;
    virtualisation.libvirtd.enable = true;

    environment.systemPackages = with pkgs; [
      claude-code opencode ripes hugo bambu-studio gtk3 gtk4
      gnome-boxes gemini-cli vim-full github-cli codex
      rustc cargo obsidian clang tinymist typst zathura
      poppler-utils nodejs_24
    ];

    home-manager.users.ml = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "*" = {
            addKeysToAgent = "yes";
          };
          "gitlab.hpi.de" = {
            hostname = "gitlab.hpi.de";
            user = "git";
            identityFile = "~/.ssh/hpi";
            identitiesOnly = true;
          };
          "65.109.123.217" = {
            hostname = "65.109.123.217";
            user = "ml";
            identityFile = "~/.ssh/yaltluks";
            identitiesOnly = true;
          };
        };
      };
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = true;
      };
    };
  };
}
