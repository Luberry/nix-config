# SMB shares on the storage pool:
#   \\valimar\public   anyone on the LAN, no password, read/write
#   \\valimar\dylan    dylan only (set the SMB password once: smbpasswd -a dylan)
{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "valimar";
        "server min protocol" = "SMB2_10";
        # Guest access to public is unauthenticated, so keep it to the LAN.
        "hosts allow" = "10.8.2. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "map to guest" = "Bad User";
        "guest account" = "nobody";
      };
      public = {
        "path" = "/storage/storage/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        # Guest writes are owned by a dedicated account; members of the "share"
        # group (dylan, and any future users) can manage them.
        "force user" = "smbguest";
        "force group" = "share";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
      dylan = {
        "path" = "/storage/storage/private/dylan";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "dylan";
        "create mask" = "0600";
        "directory mask" = "0700";
      };
    };
  };
  users.groups.share = { };
  users.users.smbguest = {
    isSystemUser = true;
    group = "share";
  };
  users.users.dylan.extraGroups = [ "share" ];

  # Don't serve the share paths before the pool is mounted.
  systemd.services.samba-smbd.unitConfig.RequiresMountsFor = [ "/storage/storage" ];

  # Show up in Windows' Network view.
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
