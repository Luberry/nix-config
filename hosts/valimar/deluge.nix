# Deluge behind PIA (binhex/arch-delugevpn handles the VPN and its kill switch)
# and FlexGet feeding it, as containers, same images and config dirs as the old
# docker-compose setup. Downloads land in the public share owned the same way
# as everything else there (smbguest:share, group-writable).
{
  config,
  pkgs,
  lib,
  ...
}:
let
  configDir = "/storage/storage/docker/config";
  public = "/storage/storage/public";
  # PIA has no port forwarding on US servers; Mexico has it and is the closest
  # to Texas (Canadian ones like ca-toronto.pvt.site also forward).
  wgEndpoint = "mexico.pvt.site:1337";
  owner = {
    PUID = toString config.users.users.smbguest.uid;
    PGID = toString config.users.groups.share.gid;
  };
in
{
  # VPN_USER=... and VPN_PASS=... for PIA.
  sops.secrets.delugevpn-env.sopsFile = ../../secrets/valimar.yaml;

  # The container's iptables kill switch needs these on the host.
  boot.kernelModules = [
    "iptable_mangle"
    "wireguard"
  ];

  virtualisation.oci-containers.containers = {
    delugevpn = {
      image = "binhex/arch-delugevpn:2.2.0-8-01";
      ports = [
        "8112:8112" # web UI
        "58846:58846" # daemon (flexget connects here)
        "58946:58946" # incoming peers
        "58946:58946/udp"
        "8118:8118" # privoxy
      ];
      volumes = [
        "${public}:/data"
        "${configDir}/deluge:/config"
      ];
      environment = owner // {
        TZ = "America/Chicago";
        UMASK = "002";
        VPN_ENABLED = "yes";
        VPN_PROV = "pia";
        # PIA wireguard config is generated into /config/wireguard/wg0.conf on
        # first start; its Endpoint is pinned to wgEndpoint (see preStart).
        VPN_CLIENT = "wireguard";
        # Only use PIA endpoints that support port forwarding (not the US ones);
        # the forwarded port is set as deluge's incoming port automatically.
        STRICT_PORT_FORWARD = "yes";
        ENABLE_PRIVOXY = "yes";
        LAN_NETWORK = "10.8.2.0/24";
        NAME_SERVERS = "1.1.1.1,209.222.18.222,37.235.1.174,8.8.8.8,209.222.18.218,37.235.1.177,8.8.4.4";
        DEBUG = "false";
      };
      environmentFiles = [ config.sops.secrets.delugevpn-env.path ];
      # Kernel wireguard needs these, per the image docs.
      extraOptions = [
        "--privileged"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      ];
    };

    flexget = {
      image = "wiserain/flexget";
      # Web UI on :5050/flexget; reaches deluge on 10.8.2.226:58846.
      extraOptions = [ "--network=host" ];
      volumes = [
        "${public}:/data"
        "${configDir}/flexget:/config"
      ];
      environment = owner // {
        TZ = "America/Chicago";
      };
      dependsOn = [ "delugevpn" ];
    };
  };
  # The image only reads the server from wg0.conf, so pin it before each start.
  # (On the very first start the file doesn't exist yet; it's generated with
  # the default endpoint, and this takes effect from the next restart.)
  systemd.services.docker-delugevpn.preStart = ''
    wg0=${configDir}/deluge/wireguard/wg0.conf
    if [ -f "$wg0" ]; then
      sed -i 's|^Endpoint = .*|Endpoint = ${wgEndpoint}|' "$wg0"
    fi
  '';
  systemd.services.docker-delugevpn.unitConfig.RequiresMountsFor = [
    "${configDir}/deluge"
    public
  ];
  systemd.services.docker-flexget.unitConfig.RequiresMountsFor = [
    "${configDir}/flexget"
    public
  ];
}
