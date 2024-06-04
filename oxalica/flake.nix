{
  description = "A rust flake using oxalica's overlay";

  inputs = {
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };

  outputs = inputs: let
    # name = "rust-hello"; defaults to ${pname}-${version} so use that
    pname = "rust-hello";
    version = "0.0.1";
    src = pkgs.lib.cleanSource ./.;
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      system = system;
      overlays = [(import inputs.rust-overlay)];
    };
  in {
    packages.${system}.default =
      (pkgs.makeRustPlatform {
        cargo = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
        rustc = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
      })
      .buildRustPackage {
        inherit pname src version;
        cargoLock.lockFile = ./Cargo.lock;
        nativeBuildInputs = [pkgs.pkg-config];
        buildInputs = [pkgs.libpulseaudio];
      };
    devShells.${system}.default = pkgs.mkShell {
      inputsFrom = [inputs.self.packages.${system}.default];
      nativeBuildInputs = [
        pkgs.rust-bin.selectLatestNightlyWith
        (toolchain: toolchain.default)
        pkgs.convco
      ];
    };
  };
}
