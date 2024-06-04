{
  description = "A rust flake using nixpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
    packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
      inherit pname src system version;
      cargoLock = {
        lockFile = ./Cargo.lock;
      };
      # If we are on linux, use pkg-config to assist the linker in getting shared object files
      nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [pkgs.pkg-config];
      buildInputs = [
        # these are things needed in the *consumer* system at *run* time, but which need to be linked against
        pkgs.libpulseaudio
      ];
      meta = {
        description = "A quick hello world";
        homepage = "https://github.com/0x50F1A";
        license = [pkgs.lib.licenses.mit];
        maintainers = [];
      };
    };
    devShells.${system}.default = pkgs.mkShell {
      inputsFrom = [inputs.self.packages.${system}.default];
      nativeBuildInputs = [
        pkgs.convco
      ];
    };
  };
}
