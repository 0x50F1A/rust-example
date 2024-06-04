{
  description = "A rust flake using dream2nix";

  inputs = {
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      system = system;
    };
  in {
    packages.${system}.default = inputs.dream2nix.lib.evalModules {
      packageSets.nixpkgs = pkgs;
      modules = [
        {
          imports = [
            inputs.dream2nix.modules.dream2nix.rust-cargo-lock
            inputs.dream2nix.modules.dream2nix.rust-crane
          ];

          mkDerivation = {
            src = ./.;
            nativeBuildInputs = [pkgs.pkg-config];
            buildInputs = [pkgs.libpulseaudio];
          };

          deps = {nixpkgs, ...}: {
            inherit (nixpkgs) stdenv;
          };

          name = "app";
          version = "0.1.0";
          paths.projectRoot = ./.;
          paths.projectRootFile = "flake.nix";
          paths.package = ./.;
        }
      ];
    };
  };
}
