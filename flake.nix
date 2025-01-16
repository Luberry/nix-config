{
	description = "NixOS configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
		home-manager.url = "github:nix-community/home-manager/release-24.11";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
		sops-nix.url = "github:Mic92/sops-nix";
    		p81.url = "github:devusb/p81.nix";  
  		p81.inputs.nixpkgs.follows = "nixpkgs";    
	 	sentinelone.url = "github:devusb/sentinelone.nix";
		nix-packages.url = "github:Luberry/nix-packages";    
		nix-packages.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = inputs@{ nixpkgs, home-manager,sops-nix, ... }: {
		nixosConfigurations = {
			dkozicki-thinkbook = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./configuration.nix
					./devices/thinkbook/default.nix
					./hosts/dkozicki-thinkbook/packages.nix
					sops-nix.nixosModules.sops
						home-manager.nixosModules.home-manager
						{
							home-manager={
								useGlobalPkgs = true;
								useUserPackages = true;
								extraSpecialArgs = {inherit inputs;};
								users.dkozicki.imports = [
									./home
									./home/work.nix
								];
							};

						}
				];
			};
		};
	};
}
