{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  networking.hostName = "valimar"; # Define your hostname.
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "en*";
      address = [ "10.8.2.226/24" ];
      gateway = [ "10.8.2.1" ];
      # Its own pi-hole; 1.1.1.1 keeps valimar resolving if pi-hole is down.
      # (The router no longer answers DNS itself.)
      dns = [
        "127.0.0.1"
        "1.1.1.1"
      ];
      networkConfig.DHCP = "no";
    };
  };
}
