
{
  description = "elcasnix's agentic dev environment";

  inputs = {
    # PINNED to a stable release — "so we don't get surprises."
    # Match the release to your existing stateVersion, then upgrade deliberately.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    voxtype.url = "github:peteonrails/voxtype";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-unstable, voxtype, }:
  {
    # "nixos" = your hostname (networking.hostName). Rename both together if you
    # ever change it, or pass --flake .#nixos explicitly.
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";          # aarch64-linux on ARM hardware
      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            pkgs-unstable = nixpkgs-unstable.legacyPackages."x86_64-linux";
            voxtype-pkgs = voxtype.packages."x86_64-linux";
            };
          # "This is the key" — this user is managed by home.nix
          home-manager.users.elcasnix = import ./home.nix;
        }
      ];
    };
  };
}
