{
  self,
  inputs,
  withSystem,
  config,
  ...
}:

let
  mkSpecialArgs =
    inputs':
    let
      inherit (config.flake) overlays legacyNixosModules;
    in
    {
      flake = {
        inherit
          self
          inputs
          inputs'
          overlays
          ;
        inherit config;
      };
      modules = legacyNixosModules;
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
              (builtins.attrValues modules.common)
              ++ (with modules.snippets; [
                cloud.user
                cloud.ssh
              ]);
            services.timesyncd.enable = lib.mkForce true;
          };
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
