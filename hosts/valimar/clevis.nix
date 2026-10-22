# Unlock the LUKS root at boot via clevis, pinned to the tang server at
# 10.8.2.227:7575. The initrd brings up a static address so it can reach tang.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Must match the boot.initrd.luks.devices name in hardware-configuration.nix.
  luksDevice = "cryptroot";
in
{
  boot.initrd = {
    systemd = {
      enable = true;
      network = {
        enable = true;
        networks."10-lan" = {
          matchConfig.Name = "en*";
          address = [ "10.8.2.226/24" ];
          networkConfig.DHCP = "no";
        };
      };
    };
    # Onboard Realtek NIC, needed in initrd to reach tang.
    availableKernelModules = [ "r8169" ];
    clevis = {
      enable = true;
      useTang = true;
      # Kept on valimar rather than in the repo, since anyone with this file
      # and network access to tang can unlock the disk. Copied into the initrd
      # when the bootloader is installed. It wraps a dedicated LUKS key slot:
      #   head -c 64 /dev/urandom > /tmp/tang.key
      #   cryptsetup luksAddKey /dev/disk/by-partlabel/cryptroot /tmp/tang.key
      #   clevis encrypt tang '{"url":"http://10.8.2.227:7575"}' < /tmp/tang.key > /etc/clevis/cryptroot.jwe
      #   shred -u /tmp/tang.key
      devices.${luksDevice}.secretFile = "/etc/clevis/${luksDevice}.jwe";
    };
  };
  environment.systemPackages = [ pkgs.clevis ];
}
