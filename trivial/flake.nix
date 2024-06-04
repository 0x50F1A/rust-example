{
  description = "A very basic rust flake";

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
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      inherit pname src system version;
      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = ./Cargo.lock;
      };
      nativeBuildInputs = [
        # These are things needed in our *native* system at *build* time
        # pkgs.autoPatchelfHook # One can manually link libraries such as "libpulseaudio", or one can use autoPatchelfHook to have this try and happen automagically.
        pkgs.pkg-config # pkg-config, however is a better option for open-source compilation since it is configurable and consumable with pkg-config libraries
        pkgs.cargo
        pkgs.llvmPackages.lld # This allows us to link much faster
        /*
        You can either manually grab cargo dependencies (not trivial since networking in blocked in the build sandbox),
        or use this hook to grab get the dependencies given by cargoDeps
        */
        pkgs.rustPlatform.cargoSetupHook
      ];
      buildInputs = [
        # these are things needed in the *consumer* system at *run* time, but which need to be linked against
        pkgs.libpulseaudio
      ];
      buildPhase = ''
        cargo build --release
      '';
      installPhase = ''
        # mkdir -p $out/bin
        # cp target/release/hello $out/bin/hello
        # chmod +x $out
        install -m755 -D target/release/${pname} $out/bin/${pname}
      '';
    };
  };
}
