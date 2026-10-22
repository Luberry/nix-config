# Monitoring, converted from the old dockprom compose stack:
# prometheus + exporters + pushgateway, grafana with dockprom's dashboards
# (read from storage), and caddy in front of grafana (valimar.local) and the
# <service>.home.arpa sites (openhab, plex, jellyfin, deluge, flexget, immich,
# pihole).
#
# Prometheus and the exporters only listen on localhost; grafana is the way in.
# Job names match dockprom's so its dashboards keep working.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  dashboards = "/storage/storage/docker/dockprom/grafana/provisioning/dashboards";
  exporters = config.services.prometheus.exporters;
in
{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    retentionTime = "200h";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    scrapeConfigs = [
      {
        job_name = "nodeexporter";
        scrape_interval = "5s";
        static_configs = [ { targets = [ "127.0.0.1:${toString exporters.node.port}" ]; } ];
      }
      {
        job_name = "cadvisor";
        scrape_interval = "5s";
        static_configs = [ { targets = [ "127.0.0.1:${toString config.services.cadvisor.port}" ]; } ];
      }
      {
        job_name = "prometheus";
        scrape_interval = "10s";
        static_configs = [ { targets = [ "127.0.0.1:${toString config.services.prometheus.port}" ]; } ];
      }
      {
        job_name = "pushgateway";
        scrape_interval = "10s";
        honor_labels = true;
        static_configs = [ { targets = [ "127.0.0.1:9091" ]; } ];
      }
      {
        job_name = "dfpoller";
        scrape_interval = "5s";
        static_configs = [ { targets = [ "127.0.0.1:9101" ]; } ];
      }
      {
        job_name = "caddy";
        static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
      }
      {
        job_name = "nut-primary";
        metrics_path = "/ups_metrics";
        params.ups = [ "ups" ];
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString exporters.nut.port}" ];
            labels.ups = "primary";
          }
        ];
      }
    ];
    pushgateway = {
      enable = true;
      web.listen-address = "127.0.0.1:9091";
    };
    exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      enabledCollectors = [ "systemd" ];
    };
  };

  # dfpoller (my own df exporter) always listens on :9101; the firewall keeps it
  # local.
  systemd.services.dfpoller = {
    description = "Prometheus exporter for df";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = lib.getExe (pkgs.callPackage ../../pkgs/dfpoller.nix { });
      DynamicUser = true;
      Restart = "on-failure";
    };
  };

  services.cadvisor = {
    enable = true;
    listenAddress = "127.0.0.1";
    # 8080 is taken by pi-hole's web UI once that's converted.
    port = 8081;
  };

  sops.secrets = {
    grafana-admin-password = {
      sopsFile = ../../secrets/valimar.yaml;
      owner = "grafana";
    };
    grafana-secret-key = {
      sopsFile = ../../secrets/valimar.yaml;
      owner = "grafana";
    };
  };
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "valimar.local";
        root_url = "https://valimar.local/grafana/";
        serve_from_sub_path = true;
      };
      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
        secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
      };
      users.allow_sign_up = false;
    };
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-clock-panel
      grafana-piechart-panel
    ];
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "dockprom";
          options.path = dashboards;
        }
      ];
    };
  };
  systemd.services.grafana.unitConfig.RequiresMountsFor = [ dashboards ];

  services.caddy = {
    enable = true;
    virtualHosts."valimar.local" = {
      serverAliases = [
        "valimar.home.arpa"
        "10.8.2.226"
      ];
      extraConfig = ''
        tls internal

        redir / /grafana/
        redir /grafana /grafana/
        handle /grafana/* {
          reverse_proxy 127.0.0.1:3000
        }
      '';
    };
    # Pi-hole resolves these to valimar. openHAB's UI loads assets from absolute
    # paths (/js, /rest, ...), so it needs its own hostname, not a sub-path.
    virtualHosts."openhab.home.arpa".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:8180 {
        header_down +Access-Control-Allow-Origin *
        header_down +Access-Control-Allow_Credentials true
        header_down +Access-Control-Allow-Headers Authorization,Accept,Origin,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range
        header_down +Access-Control-Allow-Methods GET,POST,OPTIONS,PUT,DELETE,PATCH
      }
    '';
    virtualHosts."plex.home.arpa".extraConfig = ''
      tls internal
      redir / /web/
      reverse_proxy 127.0.0.1:32400
    '';
    virtualHosts."jellyfin.home.arpa".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:8096
    '';
    virtualHosts."deluge.home.arpa".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:8112
    '';
    virtualHosts."flexget.home.arpa".extraConfig = ''
      tls internal
      redir / /flexget/
      reverse_proxy 127.0.0.1:5050
    '';
    virtualHosts."immich.home.arpa".extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:2283
    '';
    virtualHosts."pihole.home.arpa".extraConfig = ''
      tls internal
      redir / /admin/
      reverse_proxy 127.0.0.1:8080
    '';
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
