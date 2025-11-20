{
  inputs,
  ...
}:

{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        name = "NixConsole";
        motd = ''
          {italic}{99}🦾 Life in Nix 👾{reset}
          $(type -p menu &>/dev/null && menu)
        '';
        packages = with pkgs; [
          sops
          deploy-rs
        ];
      };
    };
}
