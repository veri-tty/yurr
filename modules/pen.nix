{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.gobuster
    pkgs.exiftool
    pkgs.github-copilot-cli
    pkgs.burpsuite
    pkgs.binaryninja-free
    pkgs.file
    pkgs.solc
    pkgs.awscli2
    pkgs.curlie
    pkgs.python3
    pkgs.responder
    pkgs.gobuster
    pkgs.mariadb
    pkgs.samba
    pkgs.nmap
    pkgs.inetutils
    pkgs.wireshark
    pkgs.metasploit
    pkgs.armitage
    pkgs.python313Packages.impacket
    pkgs.openvpn
  ];
  programs.ghidra.enable = true;
}
