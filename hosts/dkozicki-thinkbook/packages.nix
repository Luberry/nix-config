{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.p81.nixosModules.perimeter81
    inputs.sentinelone.nixosModules.sentinelone
    inputs.sops-nix.nixosModules.sops
  ];
  environment.systemPackages = with pkgs; [
    slack
    teams-for-linux
  ];

  services.perimeter81.enable = true;
  sops = {
    secrets.s1_mgmt_token = {
      sopsFile = ../../secrets/sentinelone.yaml;
    };
  };
  services.sentinelone = {
    enable = true;
    serialNumber = "MP2KMR98";
    sentinelOneManagementTokenPath = config.sops.secrets.s1_mgmt_token.path;
    email = "dylan.kozicki@imubit.com";
  };
}
