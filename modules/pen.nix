{ pkgs, config, ... }:
{
  environment.systemPackages = [
    # Existing tools
    pkgs.netcat-gnu
    pkgs.goose-cli
    pkgs.imagemagick
    pkgs.github-copilot-cli
    pkgs.burpsuite
    pkgs.binaryninja-free
    pkgs.file
    pkgs.solc
    pkgs.awscli2
    pkgs.curlie
    pkgs.python3
    pkgs.mariadb
    pkgs.samba
    pkgs.inetutils
    pkgs.wireshark
    pkgs.metasploit
    pkgs.armitage
    pkgs.python313Packages.impacket
    pkgs.openvpn

    # Network & Reconnaissance
    pkgs.nmap
    pkgs.masscan
    pkgs.rustscan
    pkgs.amass
    pkgs.subfinder
    pkgs.nuclei
    pkgs.fierce
    pkgs.dnsenum
    pkgs.theharvester
    pkgs.responder
    pkgs.netexec
    pkgs.enum4linux-ng

    # Web Application Security
    pkgs.gobuster
    pkgs.feroxbuster
    pkgs.ffuf
    pkgs.dirb
    pkgs.httpx
    pkgs.katana
    pkgs.nikto
    pkgs.sqlmap
    pkgs.wpscan
    pkgs.arjun
    pkgs.dalfox
    pkgs.wafw00f

    # Password & Authentication
    pkgs.hydra
    pkgs.john
    pkgs.hashcat
    pkgs.medusa
    pkgs.evil-winrm
    pkgs.hash-identifier
    pkgs.ophcrack

    # Binary Analysis & Reverse Engineering
    pkgs.gdb
    pkgs.radare2
    pkgs.binwalk
    pkgs.checksec
    pkgs.volatility3
    pkgs.foremost
    pkgs.steghide
    pkgs.exiftool
  ];
  programs.ghidra.enable = true;
}
