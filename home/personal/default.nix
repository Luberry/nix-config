{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs = {
    git = {
      userName = "Dylan Kozicki";
      userEmail = "dylan.kozicki@gmail.com";
      signing = {
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
      extraConfig.gpg.format = "ssh";
    };
  };
  home = {
    packages = with pkgs; [
      freecad-wayland
      pico-sdk
    ];

  };
}
