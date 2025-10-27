{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.claude-code
    pkgs.codex
    pkgs.rustc
    pkgs.cargo
    pkgs.obsidian
    pkgs.clang
    pkgs.tinymist
    pkgs.typst
    pkgs.zathura
    pkgs.poppler-utils
    pkgs.nodejs_24
  ];

  home-manager.users.ml = {
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "gitlab.hpi.de" = {
          hostname = "gitlab.hpi.de";
          user = "git";
          identityFile = "~/.ssh/hpi";
          identitiesOnly = true;
        };
      };
    };
    programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    };
  };
}
