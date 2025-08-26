{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
environment.systemPackages = with pkgs;[
  wlroots_0_19
];
}
