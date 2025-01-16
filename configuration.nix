# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
nix.settings.experimental-features="nix-command flakes";

# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	services.xserver.xkb = {
		layout="us";
		variant="colemak";
	};
	console = {
		earlySetup = true;
		useXkbConfig = true;
	};

	networking.hostName = "dkozicki-thinkbook"; # Define your hostname.
# Pick only one of the below networking options.
		networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

# Set your time zone.
		time.timeZone = "America/Chicago";


# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
# Enable the X11 windowing system.
	services.xserver.enable = true;


	environment.systemPackages = with pkgs; [
		grim # screenshot functionality
			slurp # screenshot functionality
			wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
			mako # notification system developed by swaywm maintainer
			ulauncher
			rxvt-unicode
			usbutils
			vim
zip
unzip
killall
ssh-to-age
sops
lm_sensors
xsecurelock
bash
playerctl
iproute2
plexamp
	];
# Enable the gnome-keyring secrets vault. 
# Will be exposed through DBus to programs willing to store secrets.
	services.gnome.gnome-keyring.enable = true;

	nixpkgs.config.allowUnfree = true;
# Configure keymap in X11
# services.xserver.xkb.layout = "us";
# services.xserver.xkb.options = "eurosign:e,caps:escape";

# Enable CUPS to print documents.
# services.printing.enable = true;

# Enable sound.
# hardware.pulseaudio.enable = true;
# OR
	services.pipewire = {
		enable = true;
		pulse.enable = true;
	};

# Enable touchpad support (enabled default in most desktopManager).
	services.libinput.enable = true;
 services.libinput.touchpad.naturalScrolling=true;

	users.users={
		dkozicki={
			initialPassword="password";
			isNormalUser=true;
			openssh.authorizedKeys.keys=[
				"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU1RjJ01Kw/T1V8pmghbI86+nQlJ8HidlFNNBNHHFoE6mXvhaFw8xrLRNB/4lb17KY2aaLg3MdxdDZSQQlys9h7cT2+EU2cPjjz1gNYeUVTye6L6EMgSh2tjKUzg9hFXvDbQS0AaP5FJeIqeHnnga7B8emdlbokUjMRVi0mGphe2lFbR1ucGH8mxVf6Ktn0pKupxlQ5Q+q/4LuhqTwJOs8Qws3d1sjEmN89ngnvk/zQ2eMznDOa+LXsbcBLGwg3EacazXUOMBex5gDZEPHeF8CJr3JhKaDWRDWjfxH1XBL1w2leI3Iw8R3eHsslGYTpylNKwr5eBsOr+R4OS+MK1cu4F0RgXt86BzzKmfBp4qpOv9nkb7u7F7FrIxvlG3hJ06VJawYrok3ZcWSU7/IDaf9Zer+cFvCCgGKRxgC1Br378rZ3boZBOiiwf2BxFcW7vJxzVYEV6mk4yvS4OI7RvGykl6jmOH5O//jf4WNcKhpm3yIr3lnHqw3DjqeRKbIUMM="
					"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaZpyQPXMZh5gUOouvvn7cxAgMX42PZ+9xuBNdZu5dQ"

			];
			extraGroups = [
				"wheel"
					"dialout"
					"bluetooth"
					"docker"
					"plugdev"
			];
			shell=pkgs.zsh;
		};
	};
	services.openssh = {
		enable = true;
		settings = {
			PermitRootLogin = "no";
			PasswordAuthentication = false;
		};
	};


	programs = {
		firefox.enable = true;
# enable sway window manager
		sway = {
			enable = true;
			wrapperFeatures.gtk = true;
		};
		nm-applet.enable=true;
		zsh = {
enable=true;
ohMyZsh.enable=true;
};
	};
 services.xserver.displayManager.gdm.enable=true; 
security.pam.services.sudo.fprintAuth=true;
security.pam.services.gdm.fprintAuth=true;

fonts.packages = with pkgs; [
powerline-fonts
];
security.polkit.enable = true;
services.touchegg.enable=true;
services.avahi.enable=true;
virtualisation.docker.enable=true;
services.blueman.enable=true;
# List packages installed in system profile. To search, run:
# $ nix search wget
# environment.systemPackages = with pkgs; [
#   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
#   wget
# ];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# Copy the NixOS configuration file and link it from the resulting system
# (/run/current-system/configuration.nix). This is useful in case you
# accidentally delete configuration.nix.
# system.copySystemConfiguration = true;

# This option defines the first version of NixOS you have installed on this particular machine,
# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
#
# Most users should NEVER change this value after the initial install, for any reason,
# even if you've upgraded your system to a new NixOS release.
#
# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
# to actually do that.
#
# This value being lower than the current NixOS release does NOT mean your system is
# out of date, out of support, or vulnerable.
#
# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
# and migrated your data accordingly.
#
# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "24.11"; # Did you read the comment?

}


