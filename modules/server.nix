{ config, lib, pkgs, ... }:
let
  cfg = config.modules.server;
in
{
  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;

    # Open firewall for Portainer
    networking.firewall.allowedTCPPorts = [ 9000 9443 ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        portainer = {
          image = "portainer/portainer-ce:latest";
          ports = [
            "9000:9000"   # HTTP
            "9443:9443"   # HTTPS
          ];
          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock"
            "/var/lib/portainer:/data"
          ];
          extraOptions = [ "--restart=always" ];
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/portainer 0750 root root -"
    ];
  };
}
