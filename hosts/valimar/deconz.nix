# deCONZ (Zigbee gateway for the ConBee II), native module.
# Data was migrated from the old container's /storage/storage/docker/config/deconz
# into /var/lib/deconz/.local/share/dresden-elektronik/deCONZ.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.deconz = {
    enable = true;
    # The container ran 2.33.2; nixpkgs is older and shouldn't open its database.
    package = pkgs.deconz.overrideAttrs (_: rec {
      version = "2.33.2";
      src = pkgs.fetchurl {
        url = "https://deconz.dresden-elektronik.de/ubuntu/stable/deconz-${version}-qt5.deb";
        sha256 = "09a2lrryma0jk7xvjc5cax3lhvwck9wrg51dkghv5k19zanvxbyk";
      };
    });
    device = "/dev/serial/by-id/usb-dresden_elektronik_ingenieurtechnik_GmbH_ConBee_II_DE2130102-if00";
    # Same ports as the old container, which openHAB's deCONZ bridge uses.
    listenAddress = "0.0.0.0";
    httpPort = 8280;
    wsPort = 8643;
    openFirewall = true;
  };
}
