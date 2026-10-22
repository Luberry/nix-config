{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  users.users = {
    dylan = {
      initialPassword = "password";
      isNormalUser = true;
      openssh.authorizedKeys.keys = import ./ssh-keys.nix;
      extraGroups = [
        "wheel"
        "dialout"
        "docker"
        "plugdev"
      ];
      shell = pkgs.zsh;
    };
  };
}
