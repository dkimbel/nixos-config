{
  description = "MacOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    }; 
    homebrew-cask-fonts = {
      url = "github:homebrew/homebrew-cask-fonts";
      flake = false;
    };
    mkAlias = {
      url = "github:reckenrode/mkAlias";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, homebrew-cask-fonts, nixpkgs, mkAlias, rust-overlay }:
    let
      user = "dk";
      systems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      devShell = system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ bashInteractive git ];
          shellHook = with pkgs; ''
            export EDITOR=hx
          '';
        };
      };
    in
    {
      devShells = forAllSystems devShell;
      darwinConfigurations = let user = "dk"; in {
        macos = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
            })
            { _module.args = { inherit mkAlias; }; }
            {
              nix-homebrew = {
                enable = true;
                user = "${user}";
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle; 
                  "homebrew/homebrew-cask-fonts" = homebrew-cask-fonts;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            ./darwin
          ];
        };
      };
  };
}
