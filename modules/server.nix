{ config, lib, pkgs, ... }:
let
  cfg = config.modules.server;
in
{
  config = lib.mkIf cfg.enable {
    services.immich.enable = true;
    virtualisation.docker.enable = true;

    # Open firewall for HTTP/HTTPS
    networking.firewall.allowedTCPPorts = [ 80 443 81 ];

    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        # Nginx Proxy Manager
        nginx-proxy-manager = {
          image = "jc21/nginx-proxy-manager:latest";
          ports = [
            "80:80"
            "443:443"
            "81:81"  # Admin UI
          ];
          volumes = [
            "/var/lib/nginx-proxy-manager/data:/data"
            "/var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
          ];
          extraOptions = [ "--network=proxy-network" ];
        };

        # Affine stack
        affine-postgres = {
          image = "pgvector/pgvector:pg16";
          volumes = [ "/var/lib/affine/postgres:/var/lib/postgresql/data" ];
          environment = {
            POSTGRES_USER = "affine";
            POSTGRES_PASSWORD = "affine";
            POSTGRES_DB = "affine";
            POSTGRES_INITDB_ARGS = "--data-checksums";
            POSTGRES_HOST_AUTH_METHOD = "trust";
          };
          extraOptions = [
            "--network=affine-network"
            "--health-cmd=pg_isready -U affine -d affine"
            "--health-interval=10s"
            "--health-timeout=5s"
            "--health-retries=5"
          ];
        };

        affine-redis = {
          image = "redis:latest";
          extraOptions = [
            "--network=affine-network"
            "--health-cmd=redis-cli --raw incr ping"
            "--health-interval=10s"
            "--health-timeout=5s"
            "--health-retries=5"
          ];
        };

        affine = {
          image = "ghcr.io/toeverything/affine:stable";
          ports = [ "3010:3010" ];
          volumes = [
            "/var/lib/affine/storage:/root/.affine/storage"
            "/var/lib/affine/config:/root/.affine/config"
          ];
          environment = {
            REDIS_SERVER_HOST = "affine-redis";
            DATABASE_URL = "postgresql://affine:affine@affine-postgres:5432/affine";
            AFFINE_INDEXER_ENABLED = "false";
          };
          dependsOn = [ "affine-postgres" "affine-redis" ];
          extraOptions = [
            "--network=affine-network"
            "--network=proxy-network"
          ];
        };
      };
    };

    # Create docker networks
    systemd.services.proxy-network = {
      description = "Create Docker network for Nginx Proxy Manager";
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.docker}/bin/docker network inspect proxy-network >/dev/null 2>&1 || \
          ${pkgs.docker}/bin/docker network create proxy-network
      '';
      preStop = ''
        ${pkgs.docker}/bin/docker network rm proxy-network || true
      '';
    };

    systemd.services.affine-network = {
      description = "Create Docker network for Affine";
      after = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.docker}/bin/docker network inspect affine-network >/dev/null 2>&1 || \
          ${pkgs.docker}/bin/docker network create affine-network
      '';
      preStop = ''
        ${pkgs.docker}/bin/docker network rm affine-network || true
      '';
    };

    systemd.services.affine-migration = {
      description = "Run Affine database migrations";
      after = [ "docker.service" "affine-network.service" "docker-affine-postgres.service" "docker-affine-redis.service" ];
      requires = [ "docker-affine-postgres.service" "docker-affine-redis.service" ];
      before = [ "docker-affine.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        sleep 10
        ${pkgs.docker}/bin/docker run --rm \
          --network=affine-network \
          -v /var/lib/affine/storage:/root/.affine/storage \
          -v /var/lib/affine/config:/root/.affine/config \
          -e REDIS_SERVER_HOST=affine-redis \
          -e DATABASE_URL=postgresql://affine:affine@affine-postgres:5432/affine \
          -e AFFINE_INDEXER_ENABLED=false \
          ghcr.io/toeverything/affine:stable \
          sh -c 'node ./scripts/self-host-predeploy.js'
      '';
    };

    # Service dependencies
    systemd.services.docker-nginx-proxy-manager.after = [ "proxy-network.service" ];
    systemd.services.docker-affine.after = [ "affine-network.service" "proxy-network.service" "affine-migration.service" ];
    systemd.services.docker-affine.requires = [ "affine-migration.service" ];
    systemd.services.docker-affine-postgres.after = [ "affine-network.service" ];
    systemd.services.docker-affine-redis.after = [ "affine-network.service" ];

    systemd.tmpfiles.rules = [
      "d /var/lib/affine 0750 root root -"
      "d /var/lib/affine/storage 0750 root root -"
      "d /var/lib/affine/config 0750 root root -"
      "d /var/lib/affine/postgres 0750 root root -"
      "d /var/lib/nginx-proxy-manager 0750 root root -"
      "d /var/lib/nginx-proxy-manager/data 0750 root root -"
      "d /var/lib/nginx-proxy-manager/letsencrypt 0750 root root -"
    ];
  };
}
