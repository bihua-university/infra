{
  inputs,
  lib,
  ...
}:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, system, ... }:
    {
      devshells.default = {
        name = "NixConsole";
        motd = ''
          {italic}{99}🦾 Life in Nix 👾{reset}
          $(type -p menu &>/dev/null && menu)
        '';
        commands = [
          {
            name = "gentopo";
            help = "Generate topology svg(s)";
            command = ''
              nix build .#topology.${system}.config.output
            '';
          }
        ];
        packages = with pkgs; [
          sops
          deploy-rs
        ];
      };
      apps = {
        deploy = {
          type = "app";
          program = lib.getExe pkgs.deploy-rs;
        };
      };
    };
}
