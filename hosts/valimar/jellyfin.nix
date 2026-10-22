# Jellyfin, native module. The container's /config layout (config, data, log,
# metadata, plugins, root) matches the module's, so it points straight at the
# old config dir on the storage pool. Libraries still refer to /media, which is
# bind-mounted back into the service.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  dataDir = "/storage/storage/docker/config/jellyfin";
  media = "/storage/storage/public/Media";
  # The container ran 12.2; 26.05 only has 10.11, which can't open its database.
  unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.hostPlatform.system; };
in
{
  services.jellyfin = {
    enable = true;
    package = unstable.jellyfin;
    openFirewall = true;
    inherit dataDir;
    configDir = "${dataDir}/config";
    logDir = "${dataDir}/log";
  };
  # A fixed uid so the files on storage stay owned correctly across reinstalls;
  # shares the media library with plex and samba through the "share" group.
  users.users.jellyfin = {
    uid = 8096;
    extraGroups = [ "share" ];
  };
  users.groups.jellyfin.gid = 8096;

  systemd.services.jellyfin = {
    unitConfig.RequiresMountsFor = [
      dataDir
      media
    ];
    serviceConfig = {
      # The module's 0077 would make anything it writes into the library
      # unreadable to plex and samba.
      UMask = lib.mkForce "0002";
      BindPaths = [ "${media}:/media" ];
    };
  };
}
