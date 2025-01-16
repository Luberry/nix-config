{ config, pkgs,lib, ... }:
{
	environment.systemPackages = with pkgs; [
		slack
		teams-for-linux
	];
}
