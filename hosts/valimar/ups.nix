# NUT for the APC Smart-UPS 2200 on USB. upsmon shuts valimar down when the UPS
# reports low battery; the prometheus exporter reads it for grafana.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets.nut-upsmon.sopsFile = ../../secrets/valimar.yaml;
  sops.secrets.nut-exporter.sopsFile = ../../secrets/valimar.yaml;

  power.ups = {
    enable = true;
    mode = "standalone";
    ups.ups = {
      description = "APC Smart-UPS 2200";
      driver = "usbhid-ups";
      port = "auto";
    };
    users = {
      upsmon = {
        passwordFile = config.sops.secrets.nut-upsmon.path;
        upsmon = "primary";
      };
      # Read-only, for the prometheus exporter.
      exporter.passwordFile = config.sops.secrets.nut-exporter.path;
    };
    upsmon.monitor.ups.user = "upsmon";
  };

  services.prometheus.exporters.nut = {
    enable = true;
    listenAddress = "127.0.0.1";
    nutUser = "exporter";
    # The exporter runs as a DynamicUser, so hand it the root-owned secret as a
    # systemd credential.
    passwordPath = "/run/credentials/prometheus-nut-exporter.service/nut-password";
  };
  systemd.services.prometheus-nut-exporter.serviceConfig.LoadCredential = [
    "nut-password:${config.sops.secrets.nut-exporter.path}"
  ];
}
