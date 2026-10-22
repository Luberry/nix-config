# deCONZ (Zigbee gateway for the ConBee II), native module.
#
# Its database (paired devices, openHAB's API key, ...) stays on the storage
# pool, in the old container's config dir, so it survives a reinstall:
# it's bind-mounted to where deCONZ expects it under its state dir.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  dataDir = "/storage/storage/docker/config/deconz";
in
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

  # A fixed uid instead of the module's DynamicUser, so the files on storage
  # stay writable across reinstalls.
  users.users.deconz = {
    isSystemUser = true;
    uid = 8280;
    group = "deconz";
    extraGroups = [ "dialout" ];
  };
  users.groups.deconz.gid = 8280;

  systemd.tmpfiles.rules = [
    "d /var/lib/deconz/.local/share/dresden-elektronik/deCONZ 0750 deconz deconz -"
  ];
  systemd.services.deconz = {
    unitConfig.RequiresMountsFor = [ dataDir ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "deconz";
      Group = "deconz";
      BindPaths = [ "${dataDir}:/var/lib/deconz/.local/share/dresden-elektronik/deCONZ" ];
    };
  };
}
