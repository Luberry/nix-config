{ inputs, ... }:
let
  customPkgs = final: prev: import ../pkgs { inherit final prev; };
  modifications = final: prev: rec {
    teams-for-linux = prev.teams-for-linux.overrideAttrs (old: {
      desktopItems = [
        (prev.makeDesktopItem {
          name = old.pname;
          exec = "${old.pname} %u";
          icon = old.pname;
          desktopName = "Microsoft Teams for Linux";
          comment = old.meta.description;
          categories = [
            "Network"
            "InstantMessaging"
            "Chat"
          ];
          mimeTypes = [
            "x-scheme-handler/msteams"
          ];
        })
      ];
    });
  };
in
inputs.nixpkgs.lib.composeManyExtensions [
  customPkgs
  modifications
]
