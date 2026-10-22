# Installer ISO for valimar. Build with:
#   nix build .#nixosConfigurations.valimar-installer.config.system.build.isoImage
{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  nixpkgs.config.allowUnfree = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };
  console = {
    earlySetup = true;
    useXkbConfig = true;
  };

  hardware.enableRedistributableFirmware = true;
  # Early-load AMD microcode, same as valimar itself.
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelParams = [
    # Debugging a black screen after grub: no KMS, no splash, and print
    # through the EFI framebuffer from the very start of the kernel.
    "nomodeset"
    "earlyprintk=efi,keep"
    "keep_bootcon"
  ];
  # The old Radeon HD 5450 only displays in the firmware default (640x480)
  # GOP mode; keep grub from switching to a higher one before the kernel.
  isoImage.forceTextMode = true;
  boot.plymouth.enable = false;
  boot.consoleLogLevel = 7;

  # Reachable headless, to tell "not booting" apart from "no display":
  #   ping valimar-installer.local && ssh root@valimar-installer.local
  networking.hostName = "valimar-installer";
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = import ./ssh-keys.nix;

  environment.systemPackages = with pkgs; [
    clevis
    # For backing up the old debian install.
    dump
  ];
}
