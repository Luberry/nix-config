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
      userEmail = "dylan.kozicki@imubit.com";
      signing = {
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
      extraConfig.gpg.format = "ssh";
    };
  };

  home = {
    packages =
      with pkgs;
      let
        poetryPkgs = import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb.tar.gz";
          sha256 = "sha256:0ngw2shvl24swam5pzhcs9hvbwrgzsbcdlhpvzqc7nfk8lc28sp3";
        }) { inherit system; };
      in
      [
        dbeaver-bin
        go
        python311
        pyenv
        poetryPkgs.poetry
        postgresql.dev
        inputs.fix-python.packages.${system}.default
        openssl.bin
        openssl.dev
      ];
    file = {
      ".zshrc-extra.zsh" = {
        source = ./.zshrc.work.zsh;
      };
      ".local/bin/dmux" = {
        source = ./scripts/dmux;
      };
      ".local/bin/gmr" = {
        source = ./scripts/gmr;
      };
      ".local/bin/itfsconnect" = {
        source = ./scripts/itfsconnect;
      };
      ".local/bin/itfspod" = {
        source = ./scripts/itfspod;
      };
      ".local/bin/mdb" = {
        source = ./scripts/mdb;
      };
      ".local/bin/mrsl" = {
        source = ./scripts/mrsl;
      };
      ".local/bin/pyt" = {
        source = ./scripts/pyt;
      };
      ".local/bin/run-dlpc" = {
        source = ./scripts/run-dlpc;
      };
      ".local/bin/start-step-details" = {
        source = ./scripts/start-step-details;
      };
      ".local/bin/fix-poetry" = {
        source = ./scripts/fix-poetry;
      };
    };
  };

}
