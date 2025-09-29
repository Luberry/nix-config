{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    # Add your overlay here
    (import ../../overlays/bambu.nix)
  ];
  environment.systemPackages = with pkgs; [
    wlroots_0_19
    bambu-studio-appimage
  ];
}
