{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    # Add your overlay here
    (import ../../overlays/bambu.nix)
    (import ../../overlays/racecapture.nix)
  ];
  environment.systemPackages = with pkgs; [
    wlroots_0_19
    bambu-studio-appimage
    spacenavd
    racecapture
    go
  ];
  programs.steam.enable=true;
  sops = {
    secrets.pia = {
      sopsFile = ../../secrets/pia.yaml;
      mode="0400";
    };
  };
  services.pia = {
    enable = true;
    
    # Use the sops secret file
    credentials.credentialsFile = config.sops.secrets.pia.path;
    
    protocol = "wireguard";
    
    autoConnect = {
      enable = false;
      region = "mexico";
    };
    
    # Optional settings
    portForwarding.enable = true;
    dns.enable = true;
  };
  services.udev.packages=[pkgs.platformio];


}
