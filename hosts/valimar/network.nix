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
      dns = [ "10.8.2.1" ];
      networkConfig.DHCP = "no";
    };
  };
}
