{ final, prev, ... }:
let
  pkgs = prev;
in
{
  i3blocks-contrib = pkgs.callPackage ./i3blocks-contrib { };
}
