# Immich v3, native, with the package *and* module from nixpkgs-unstable (26.05
# only has 2.x). Migrated from the old container setup in
# /storage/storage/docker/immich by dump/restore.
#
# The database stores media paths as /data/..., so the library is bind-mounted
# there instead of rewriting paths (and immich needs no access to the private
# dir above it). Postgres keeps its data on the storage pool.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  library = "/storage/storage/private/dylan/immich-library";
  pgData = "/storage/storage/docker/postgresql/${config.services.postgresql.package.psqlSchema}";
  unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; };
in
{
  disabledModules = [ "services/web-apps/immich.nix" ];
  imports = [ "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/immich.nix" ];

  services.postgresql = {
    # Pinned so a stateVersion bump can't silently switch major versions.
    package = pkgs.postgresql_17;
    dataDir = pgData;
  };
  systemd.services.postgresql.unitConfig.RequiresMountsFor = [ pgData ];
  # postgres can't create this itself under the root-owned docker dir.
  systemd.tmpfiles.rules = [ "d ${pgData} 0700 postgres postgres -" ];

  services.immich = {
    enable = true;
    package = unstable.immich;
    # Same as the container: reachable on the LAN at :2283 (and via caddy).
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/data";
  };
  systemd.services.immich-server = {
    unitConfig.RequiresMountsFor = [ library ];
    serviceConfig.BindPaths = [ "${library}:/data" ];
  };
}
