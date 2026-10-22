# Base configuration for the headless NAS. Intentionally does not import the
# shared ../../configuration.nix, which is desktop-oriented (sway, gdm, etc).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };
  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    neovim
    git
    htop
    ncdu
    jq
    usbutils
    smartmontools
    sops
    ssh-to-age
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
  services.smartd.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
  };
  virtualisation.docker.enable = true;

  # Set to the NixOS release valimar was first installed with.
  system.stateVersion = "26.05";
}
