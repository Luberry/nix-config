{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  # The old Radeon HD 5450 only displays in the firmware default (640x480)
  # GOP mode, and debian runs it without a KMS driver. Same as the installer.
  boot.loader.systemd-boot.consoleMode = "keep";
  # /boot is the ESP; cap generations so kernels don't fill it.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelParams = [ "nomodeset" ];
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };
}
