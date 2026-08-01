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
      gscan2pdf
      speedcrunch
      lutris-free
      wineWowPackages.stagingFull
      winetricks
      uget
      prismlauncher
      ydotool
      lsb-release
      mesa-demos
      wget
      p7zip
      remmina
      cabextract
      samba4Full
      bc
      mokutil
      gettext
      android-tools
      vlc
      scrcpy
      platformio
      go
      caprine

    ];
  };
}
