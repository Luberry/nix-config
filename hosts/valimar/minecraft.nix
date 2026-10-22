# NeoForge Minecraft server, same container and world dir as the old
# docker-compose setup. The image picks the server type/version from env vars.
#
# Console: docker exec -i minecraft rcon-cli   (instead of attaching a tty)
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Owned by uid/gid 1000, the image's default user.
  dataDir = "/storage/storage/docker/minecraft";
in
{
  virtualisation.oci-containers.containers.minecraft = {
    image = "itzg/minecraft-server";
    ports = [ "25565:25565" ];
    volumes = [ "${dataDir}:/data" ];
    environment = {
      EULA = "TRUE";
      TYPE = "NEOFORGE";
      VERSION = "1.21.11";
      NEOFORGE_VERSION = "21.11.37";
      TZ = "America/Chicago";
    };
  };
  systemd.services.docker-minecraft.unitConfig.RequiresMountsFor = [ dataDir ];
}
