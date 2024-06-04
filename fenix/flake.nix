{
  description = "A rust flake using fenix";

  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
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
    };
  in {
    # https://rust-lang.github.io/rustup/concepts/profiles.html
    # fenix.packages.${system}.minimal = rustc, rust-std, cargo
    # .default = minimal ++ rust-docs, rustfmt, clippy
    packages.${system}.default = let
      toolchain = inputs.fenix.packages.${system}.default.toolchain;
    in
      (pkgs.makeRustPlatform {
        cargo = toolchain;
        rustc = toolchain;
      })
      .buildRustPackage {
        inherit pname src version;
        cargoLock.lockFile = ./Cargo.lock;
        buildInputs = [pkgs.libpulseaudio];
      };
    devShells.${system}.default = pkgs.mkShell {
      inputsFrom = [inputs.self.packages.${system}.default];
      nativeBuildInputs = [
        inputs.fenix.packages.${system}.rust-analyzer
        pkgs.convco
      ];
    };
  };
}
