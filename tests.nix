{
  self,
  inputs,
  withSystem,
  config,
  ...
}:

let
  mkSpecialArgs = inputs': {
    flake = {
      inherit
        self
        inputs
        inputs'
        ;
      inherit config;
    };
    modules = config.flake.legacyNixosModules;
  };
in
{

  flake.checks."x86_64-linux" = withSystem "x86_64-linux" (
    { pkgs, inputs', ... }:
    {
      cloud-base = pkgs.testers.runNixOSTest {
        name = "Basic NixOS in VPS";
        nodes.machine =
          { lib, modules, ... }:
          {
            imports =
              config.infra.load-modules
              ++ (with modules.snippets; [
                cloud.user
                cloud.ssh
              ]);
            services.timesyncd.enable = lib.mkForce true;
            nixpkgs.overlays = config.infra.overlays;
          };
        node.pkgsReadOnly = false;
        node.specialArgs = mkSpecialArgs inputs';
        testScript = # python
          ''
            machine.start()
            machine.wait_for_unit("default.target")
            machine.succeed("uname -a")
            machine.succeed("id bhu")
          '';
      };
    }
  );
}
