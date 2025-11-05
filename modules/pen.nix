{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.curlie
    pkgs.metasploit
    pkgs.armitage
    pkgs.openvpn
  ];

}
