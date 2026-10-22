# Pi-hole, native module. Started fresh (the old container's config lived on
# debian's root disk). The router does DHCP and hands out 10.8.2.226 for DNS.
#
# Local names live under home.arpa and all point at valimar; caddy routes them.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # FTLCONF_webserver_api_password=..., since pihole.toml is read-only on NixOS.
  sops.secrets.pihole-env.sopsFile = ../../secrets/valimar.yaml;

  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    openFirewallWebserver = true;
    lists = [
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        description = "Steven Black's unified adlist";
      }
      {
        # Merged list of many public adlists (https://github.com/r0xd4n3t/pihole-adblock-lists).
        url = "https://raw.githubusercontent.com/r0xd4n3t/pihole-adblock-lists/main/pihole_adlists.txt";
        description = "r0xd4n3t curated adlists";
      }
      {
        url = "https://gist.githubusercontent.com/mcrumm/972070dfe67d44ed61c4247563cbf07c/raw/62ad84e3df6404d5b05dacd5bcfdc5e97e97a1ea/LG%2520Smart-TV%2520Blocklist%2520Adlist%2520(for%2520PiHole)";
        description = "LG Smart-TV telemetry/ads";
      }
      {
        # Exceptions to the blocklists above; add a domain per line.
        url = "file://${pkgs.writeText "pihole-allowlist" ''
          thepiratebay.org
          www.thepiratebay.org
          # YouTube watch history (s.youtube.com is a CNAME to video-stats).
          s.youtube.com
          video-stats.l.google.com
        ''}";
        type = "allow";
        description = "Local allowlist";
      }
    ];
    settings = {
      dns = {
        upstreams = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        # Bind to the LAN interface only; systemd-resolved owns 127.0.0.53:53.
        interface = "enp5s0";
        listeningMode = "BIND";
        domain = {
          name = "home.arpa";
          local = true;
        };
        hosts = [
          "10.8.2.226 valimar.home.arpa openhab.home.arpa pihole.home.arpa plex.home.arpa jellyfin.home.arpa deluge.home.arpa flexget.home.arpa immich.home.arpa"
        ];
      };
    };
  };
  services.pihole-web = {
    enable = true;
    ports = [ 8080 ];
  };
  systemd.services.pihole-ftl.serviceConfig.EnvironmentFile = config.sops.secrets.pihole-env.path;
}
