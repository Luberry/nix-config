{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  services = {
    fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-elan;
    };
    thinkfan = {
      enable = true;
    };
    acpid = {
      enable = true;
    };
  };
  programs = {
    light.enable = true;
  };
  hardware.acpilight.enable = true;

}
