# Immich, as containers from its own compose project
# (/storage/storage/docker/immich), reusing its postgres data dir as-is.
# Native NixOS immich would need a dump/restore into NixOS' postgres instead.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  dir = "/storage/storage/docker/immich";
  library = "/storage/storage/private/dylan/immich-library";
  network = "immich";
  common = {
    TZ = "America/Chicago";
    IMMICH_VERSION = "v2";
    DB_USERNAME = "postgres";
    DB_DATABASE_NAME = "immich";
  };
  # DB_PASSWORD=... and POSTGRES_PASSWORD=... (the same value).
  env = config.sops.secrets.immich-env.path;
  # Containers find each other by the compose service names.
  onNetwork = alias: [
    "--network=${network}"
    "--network-alias=${alias}"
  ];
in
{
  sops.secrets.immich-env.sopsFile = ../../secrets/valimar.yaml;

  virtualisation.oci-containers.containers = {
    immich_server = {
      image = "ghcr.io/immich-app/immich-server:${common.IMMICH_VERSION}";
      ports = [ "2283:2283" ];
      volumes = [ "${library}:/data" ];
      environment = common;
      environmentFiles = [ env ];
      extraOptions = onNetwork "immich-server";
      dependsOn = [
        "immich_redis"
        "immich_postgres"
      ];
    };
    immich_machine_learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:${common.IMMICH_VERSION}";
      # Downloaded models; recreated if lost.
      volumes = [ "immich-model-cache:/cache" ];
      environment = common;
      environmentFiles = [ env ];
      extraOptions = onNetwork "immich-machine-learning";
    };
    immich_redis = {
      image = "docker.io/valkey/valkey:8@sha256:81db6d39e1bba3b3ff32bd3a1b19a6d69690f94a3954ec131277b9a26b95b3aa";
      extraOptions = onNetwork "redis";
    };
    immich_postgres = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      volumes = [ "${dir}/postgres:/var/lib/postgresql/data" ];
      environment = {
        POSTGRES_USER = common.DB_USERNAME;
        POSTGRES_DB = common.DB_DATABASE_NAME;
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      environmentFiles = [ env ];
      extraOptions = onNetwork "database" ++ [ "--shm-size=128m" ];
    };
  };

  systemd.services = lib.mkMerge [
    {
      docker-network-immich = {
        description = "Docker network for immich";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${lib.getExe config.virtualisation.docker.package} network inspect ${network} >/dev/null 2>&1 \
            || ${lib.getExe config.virtualisation.docker.package} network create ${network}
        '';
      };
    }
    (lib.genAttrs
      [
        "docker-immich_server"
        "docker-immich_machine_learning"
        "docker-immich_redis"
        "docker-immich_postgres"
      ]
      (_: {
        after = [ "docker-network-immich.service" ];
        requires = [ "docker-network-immich.service" ];
      })
    )
    {
      docker-immich_server.unitConfig.RequiresMountsFor = [ library ];
      docker-immich_postgres.unitConfig.RequiresMountsFor = [ dir ];
    }
  ];
}
