# The storage pool is imported in stage 2, after the LUKS root is unlocked
# (via clevis/tang) and sops-nix has decrypted the pool key to /run/secrets.
# Point the pool's encryption root at it once, on valimar:
#   zfs set keylocation=file:///run/secrets/storage-key storage/storage
{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot.supportedFilesystems = [ "zfs" ];
  # ZFS refuses to import pools without a stable host id.
  networking.hostId = "4d29e3be";
  boot.zfs.extraPools = [ "storage" ];
  boot.zfs.forceImportRoot = false;
  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };
  sops.secrets.storage-key = {
    sopsFile = ../../secrets/valimar.yaml;
    mode = "0400";
  };
}
