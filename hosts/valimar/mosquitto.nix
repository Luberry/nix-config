# Mosquitto, native module. Same setup as the old container's mosquitto.conf:
# one anonymous listener on 1883 with persistence. Retained messages were
# migrated from /storage/storage/docker/config/mosquitto/data/mosquitto.db.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
        acl = [ "topic readwrite #" ];
      }
    ];
  };
  networking.firewall.allowedTCPPorts = [ 1883 ];
}
