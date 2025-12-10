{ pkgs, config, ... }:
{
  services.immich = {
    enable = true;
  };

  # Enable Docker for container-based services
  virtualisation.docker.enable = true;

  # Affine self-hosted configuration
  # Uses Docker containers for the Affine knowledge base (Notion/Miro alternative)
  # Based on official docs: https://docs.affine.pro/self-host-affine/install/docker-compose-recommend
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      affine-postgres = {
        image = "pgvector/pgvector:pg16";
        volumes = [
          "/var/lib/affine/postgres:/var/lib/postgresql/data"
        ];
        environment = {
          POSTGRES_USER = "affine";
          POSTGRES_PASSWORD = "affine";
          POSTGRES_DB = "affine";
          POSTGRES_INITDB_ARGS = "--data-checksums";
          # Required for initial setup without password prompt
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
        ];
      };
    };
  };

  # Create the Docker network for Affine services
  systemd.services.affine-network = {
    description = "Create Docker network for Affine";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker network create affine-network || true";
      ExecStop = "${pkgs.docker}/bin/docker network rm affine-network || true";
    };
  };

  # Affine database migration job - runs before the main server starts
  # This replicates the affine_migration container from official docker-compose.yml
  systemd.services.affine-migration = {
    description = "Run Affine database migrations";
    after = [
      "docker.service"
      "affine-network.service"
      "docker-affine-postgres.service"
      "docker-affine-redis.service"
    ];
    requires = [ "docker-affine-postgres.service" "docker-affine-redis.service" ];
    before = [ "docker-affine.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'sleep 10'"; # Wait for postgres/redis to be ready
      ExecStart = ''
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
  };

  # Ensure network is created before containers start
  systemd.services.docker-affine.after = [ "affine-network.service" "affine-migration.service" ];
  systemd.services.docker-affine.requires = [ "affine-migration.service" ];
  systemd.services.docker-affine-postgres.after = [ "affine-network.service" ];
  systemd.services.docker-affine-redis.after = [ "affine-network.service" ];

  # Create persistent directories for Affine
  systemd.tmpfiles.rules = [
    "d /var/lib/affine 0750 root root -"
    "d /var/lib/affine/storage 0750 root root -"
    "d /var/lib/affine/config 0750 root root -"
    "d /var/lib/affine/postgres 0750 root root -"
  ];
}
