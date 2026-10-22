{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-packages.url = "github:Luberry/nix-packages";
    nix-packages.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    i3blocks-contrib = {
      type = "github";
      owner = "vivien";
      repo = "i3blocks-contrib";
      flake = false;
    };
    pia.url = "github:mrehanabbasi/pia.nix";
    pia.inputs.nixpkgs.follows = "nixpkgs";
    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      #url = "https://flakehub.com/f/Svenum/Solaar-Flake/0.1.7.tar.gz"; # uncomment line for solaar version 1.1.19
      #url = "github:Svenum/Solaar-Flake/main"; # Uncomment line for latest unstable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fix-python.url = "github:GuillaumeDesforges/fix-python";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      systems,
      treefmt-nix,
      flake-parts,
      solaar,
      pia,
      ...
    }:
    let
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      inherit (inputs.nixpkgs.lib) genAttrs;
      inherit (self) outputs;
    in
    # but create one with normal overlays if not
    {
      overlays = {
        default = import ./overlays { inherit inputs; };
      };

      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
      # allow for extra overlays to be added later
      nixosConfigurations = {
        dylan-framework = nixpkgs.lib.nixosSystem {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;

            overlays = [
              (final: _prev: {
                unstable = import inputs.nixpkgs-unstable {
                  system = final.system;
                  config.allowUnfree = true;
                };
              })
              (import ./overlays/caprine-bankjaneo.nix)
            ];

          };

          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hosts/dylan-framework/user.nix
            ./hosts/dylan-framework/packages.nix
            ./hosts/dylan-framework/network.nix
            ./hosts/dylan-framework/pam-mount.nix
            ./devices/framework-13-intel-11g/default.nix
            sops-nix.nixosModules.sops
            solaar.nixosModules.default
            pia.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.dylan.imports = [
                  ./home/personal/username.nix
                  ./home/personal
                  ./home
                  ./home/bluetooth.nix
                  ./hosts/dylan-framework/shikane.nix
                ];
              };

            }
          ];
        };
        valimar = nixpkgs.lib.nixosSystem {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };

          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/valimar/configuration.nix
            ./hosts/valimar/user.nix
            ./hosts/valimar/network.nix
            ./hosts/valimar/clevis.nix
            ./hosts/valimar/zfs.nix
            ./hosts/valimar/samba.nix
            ./devices/valimar/default.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dylan.imports = [
                  ./home/personal/username.nix
                  ./home/shell.nix
                  ./hosts/valimar/home.nix
                ];
              };
            }
          ];
        };
        valimar-installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/valimar/installer.nix ];
        };
      };
    };
}
