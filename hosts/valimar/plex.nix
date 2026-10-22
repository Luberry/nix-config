# Plex, native module, plus its prometheus exporter.
#
# The database stays on the storage pool in the old container's config dir, so
# it survives a reinstall. Paths Plex has stored from the container days
# (/data for media, /transcode) are bind-mounted back into the service.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  configDir = "/storage/storage/docker/config/plex";
  media = "/storage/storage/public/Media";
in
{
  services.plex = {
    enable = true;
    openFirewall = true;
    # Plex keeps everything in "<dataDir>/Plex Media Server", same as the container.
    dataDir = "${configDir}/Library/Application Support";
    # The container ran 1.43.5 (Plex Pass); nixpkgs is older and shouldn't open
    # its database.
    package = pkgs.plex.override {
      plexRaw = pkgs.plexRaw.overrideAttrs (_: rec {
        version = "1.43.5.11029-6bf8af3f0";
        src = pkgs.fetchurl {
          url = "https://downloads.plex.tv/plex-media-server-new/${version}/debian/plexmediaserver_${version}_amd64.deb";
          sha256 = "1q92fvkq6c2hlazgdmdklxdygmrjspjpz0rg30j8lcxyasadybjn";
        };
      });
    };
  };
  # Shares the media library with jellyfin and samba through the "share" group.
  users.users.plex.extraGroups = [ "share" ];

  systemd.tmpfiles.rules = [ "d /var/cache/plex-transcode 0750 plex plex -" ];
  systemd.services.plex = {
    unitConfig.RequiresMountsFor = [
      configDir
      media
    ];
    serviceConfig = {
      UMask = "0002";
      BindPaths = [
        "${media}:/data"
        "/var/cache/plex-transcode:/transcode"
      ];
    };
  };

  # PLEX_TOKEN=..., kept out of the command line.
  sops.secrets.plex-exporter-env.sopsFile = ../../secrets/valimar.yaml;
  systemd.services.plex-exporter = {
    description = "Prometheus exporter for Plex";
    wantedBy = [ "multi-user.target" ];
    after = [ "plex.service" ];
    wants = [ "plex.service" ];
    serviceConfig = {
      # It exits if plex isn't up yet, so keep retrying.
      ExecStart = "${
        lib.getExe (pkgs.callPackage ../../pkgs/plex-exporter.nix { })
      } --plex-server http://127.0.0.1:32400 --listen-address 127.0.0.1:9594";
      EnvironmentFile = config.sops.secrets.plex-exporter-env.path;
      DynamicUser = true;
      Restart = "always";
      RestartSec = 10;
    };
  };
}
