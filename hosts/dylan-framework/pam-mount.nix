{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  security.pam.mount = {
    enable = true;
    createMountPoints = true;
    extraVolumes = [
      ''
        <volume
          user="dylan"
          fstype="cifs"
          server="10.8.2.226"
          path="public"
          mountpoint="~/nas-pub"
          options="sec=ntlmssp,nosuid,nodev"
        />
      ''
      ''
        <volume
          user="dylan"
          fstype="cifs"
          server="10.8.2.226"
          path="dylan"
          mountpoint="~/nas"
          options="sec=ntlmssp,nosuid,nodev"
        />
      ''
    ];
  };

  environment.systemPackages = with pkgs; [
    cifs-utils
  ];
}
