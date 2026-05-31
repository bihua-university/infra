{
  flake,
  pkgs,
  lib,
  config,
  ...
}:

let
  enable = true;
  cfg = config.services.bifrost;
  inherit (flake.inputs) bifrost;

  upstream-ui = pkgs.callPackage "${bifrost}/nix/packages/bifrost-ui.nix" {
    src = bifrost;
    version = "1.5.5";
  };
  bifrost-ui = upstream-ui.overrideAttrs (old: {
    npmDeps = old.npmDeps.overrideAttrs (_: {
      outputHash = "sha256-YniwFXRYyS8PpfabAAK0csyQLGrwUjONLTGXF7HINaI=";
    });
  });
  bifrost-http =
    (pkgs.callPackage "${bifrost}/nix/packages/bifrost-http.nix" {
      inputs = {
        nixpkgs = bifrost.inputs.nixpkgs;
      };
      src = bifrost;
      version = "1.5.5";
      inherit bifrost-ui;
    }).overrideAttrs
      (old: {
        goModules = old.goModules.overrideAttrs (_: {
          outputHash = "sha256-tNQwOEgSgBTw5YRcAt9Y6Edjjbj2pMDITJV0tRL2E38=";
        });
      });
in
{
  imports = [
    bifrost.nixosModules.bifrost
  ];

  services.bifrost = {
    inherit enable;
    package = bifrost-http;
    host = "100.76.29.108";
    port = 8084;
    logLevel = "info";
    settings = { };
    openFirewall = true;
  };

  topology.self = lib.mkIf cfg.enable {
    services.bifrost = {
      name = "BiFrost";
      info = "ai.estin.space";
      icon =
        pkgs.runCommandLocal "bifrost-icon.png"
          {
            buildInputs = [ pkgs.libwebp ];
          }
          ''
            dwebp ${cfg.package.src.outPath}/ui/public/bifrost-icon.webp -o "$out"
          '';
      details.description.text = "LLM Gateway";
    };
  };
}
