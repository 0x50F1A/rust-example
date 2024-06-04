{
  description = "Just some rust project templates";

  outputs = _: {
    templates = {
      trivial = {
        path = ./trivial;
        description = "A basic rust environment";
      };
      build = {
        path = ./build;
        description = "A more configured way to build rust projects";
      };
      crane = {
        path = ./crane;
        description = "Uses fenix to build a project using crane";
      };
      dream2nix = {
        path = ./dreamy;
        description = "A dream2nix based rust project";
      };
      fenix = {
        path = ./fenix;
        description = "Uses fenix to provide a toolchain and build";
      };
      oxalica = {
        path = ./oxalica;
        description = "Uses oxalica's rust-overlay for a toolchain";
      };
    };
  };
}
