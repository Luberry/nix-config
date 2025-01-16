{ inputs, ... }:
let
  customPkgs = final: prev: import ../pkgs { inherit final prev; };
in
inputs.nixpkgs.lib.composeManyExtensions [
  customPkgs
  modifications
]
