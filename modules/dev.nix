{ pkgs, config, ... }:
{
  #  virtualisation.docker.enable = false;
  #services.spice-webdavd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  environment.systemPackages = [
    pkgs.claude-code
    pkgs.opencode
    pkgs.ripes
    pkgs.hugo
    pkgs.bambu-studio
    pkgs.gtk3
    pkgs.gtk4
    pkgs.gnome-boxes
    pkgs.gemini-cli
    pkgs.vim-full
    pkgs.github-cli
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
}
