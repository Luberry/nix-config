# openHAB, first pass: the same container and config dirs as the old
# docker-compose setup on debian.
#
# The Z-Stick isn't passed into the container. openHAB's Z-Wave bridge talks
# to rfc2217://127.0.0.1:4000, which ser2net serves from the stick.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  configDir = "/storage/storage/docker/config/openhab";
  ser2netConfig = pkgs.writeText "ser2net.yaml" ''
    %YAML 1.1
    ---
    connection: &zstick
      accepter: telnet(rfc2217),tcp,127.0.0.1,4000
      connector: serialdev,/dev/serial/by-id/usb-0658_0200-if00,115200n81,local
      options:
        kickolduser: true
  '';
in
{
  systemd.services.ser2net = {
    description = "Serial to network proxy for the Z-Stick";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ser2net}/bin/ser2net -n -c ${ser2netConfig} -P /run/ser2net.pid";
      Restart = "always";
    };
  };

  virtualisation.oci-containers = {
    # docker is already enabled on valimar; don't pull in podman as well.
    backend = "docker";
    containers.openhab = {
      image = "openhab/openhab:5.0.0";
      extraOptions = [ "--network=host" ];
      environment = {
        TZ = "America/Chicago";
        OPENHAB_HTTP_PORT = "8180";
        OPENHAB_HTTPS_PORT = "8543";
        EXTRA_JAVA_OPTS = "-Duser.timezone=America/Chicago";
      };
      volumes = [
        "${configDir}/openhab_addons:/openhab/addons"
        "${configDir}/openhab_conf:/openhab/conf"
        "${configDir}/openhab_userdata:/openhab/userdata"
      ];
    };
  };
  systemd.services.docker-openhab = {
    after = [ "ser2net.service" ];
    wants = [ "ser2net.service" ];
    unitConfig.RequiresMountsFor = [ configDir ];
  };

  networking.firewall.allowedTCPPorts = [
    8180
    8543
  ];
}
