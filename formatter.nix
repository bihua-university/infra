{
  inputs,
  ...
}:

{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      treefmt.config = {
        projectRootFile = ".git/config";
        package = pkgs.treefmt;

        programs = {
          keep-sorted.enable = true;

          # nix
          nixfmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      };
    };
}
