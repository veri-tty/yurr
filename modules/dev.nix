{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.claude-code
    pkgs.rustc
    pkgs.cargo
    pkgs.obsidian
    pkgs.clang
    pkgs.tinymist
    pkgs.typst
  ];

  programs.vscode.enable = true;
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
  };
}
