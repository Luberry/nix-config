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
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    i3blocks-contrib = {
      type = "github";
      owner = "vivien";
      repo = "i3blocks-contrib";
      flake = false;
    };
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
            ./devices/thinkbook/default.nix
            sops-nix.nixosModules.sops
            ./hosts/dkozicki-thinkbook/packages.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.dkozicki.imports = [
                  ./home
                  ./home/work.nix
                  ./home/bluetooth.nix
                ];
              };

            }
          ];
        };
      };
    };
}
