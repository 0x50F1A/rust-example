{
  description = "A rust flake using fenix and crane";

  inputs = {
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = inputs: let
    pname = "rust-hello";
    craneLib =
      (inputs.crane.mkLib pkgs).overrideToolchain
      inputs.fenix.packages.${system}.default.toolchain;
    craneLibWithLLvm =
      craneLib.overrideToolchain
      (inputs.fenix.packages.${system}.complete.withComponents [
        "cargo"
        "llvm-tools"
        "rustc"
      ]);
    src = craneLib.cleanCargoSource (craneLib.path ./.);
    cargoArtifacts = craneLib.buildDepsOnly {
      inherit src;
    };
    commonArgs = {
      inherit src;
      strictDeps = true;
      nativeBuildInputs = [pkgs.pkg-config pkgs.makeWrapper];
      buildInputs = [pkgs.libpulseaudio];
      postInstall = ''
        wrapProgram $out/bin/${pname} \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath commonArgs.buildInputs}
      '';
    };
    crate = craneLib.buildPackage (commonArgs
      // {
        doCheck = false;
      });
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      system = system;
    };
  in {
    checks.${system} = {
      inherit crate;
      crate-clippy = craneLib.cargoClippy (commonArgs
        // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "-- --deny warnings";
        });
      crate-doc = craneLib.cargoDoc (commonArgs // {inherit cargoArtifacts;});
      crate-fmt = craneLib.cargoFmt {
        inherit src;
      };
      crate-audit = craneLib.cargoAudit {
        inherit src;
        advisory-db = inputs.advisory-db;
      };
      crate-deny = craneLib.cargoDeny {
        inherit src;
      };
      crate-nextest = craneLib.cargoNextest (commonArgs // {inherit cargoArtifacts;});
      crate-llvm-coverage = craneLibWithLLvm.cargoLlvmCov (commonArgs // {inherit cargoArtifacts;});
    };
    packages.${system}.default = crate;
    devShells.${system}.default = craneLib.devShell {
      checks = inputs.self.checks.${system};
    };
  };
}
