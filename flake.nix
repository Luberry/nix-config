{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    p81.url = "github:Luberry/p81-nix";
    p81.inputs.nixpkgs.follows = "nixpkgs";
    sentinelone.url = "github:devusb/sentinelone.nix";
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
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # allow for extra overlays to be added later
      nixosConfigurations = {
        dkozicki-thinkbook = nixpkgs.lib.nixosSystem {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
            overlays = builtins.attrValues {
              default = (import ./overlays { inherit inputs; });
            };
          };

          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hosts/dkozicki-thinkbook/user.nix
            ./hosts/dkozicki-thinkbook/packages.nix
            ./hosts/dkozicki-thinkbook/network.nix
            ./devices/thinkbook/default.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.dkozicki.imports = [
                  ./home/work/username.nix
                  ./home
                  ./home/work
                  ./home/bluetooth.nix
                ];
              };

            }
          ];
        };
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
      };
    };
}
