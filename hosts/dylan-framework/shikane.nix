{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  xdg.configFile = {
    "shikane/config.toml" = {
      enable = true;
      source = ./shikane.toml;
    };
  };
}
