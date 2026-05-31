{
  flake,
  modules,
  config,
  lib,
  ...
}:

let
  inherit (flake.inputs) quasique;
  inherit (config.sops) secrets;
  cfg = config.services.quasique;
in
{
  imports = [
    quasique.nixosModules.default
    modules.trivial.allowUnfreeList
  ];
  nixpkgs.overlays = [ quasique.overlays.default ];

  nixpkgs.superConfig.allowUnfreeList = [ "qq" ];

  sops.secrets = lib.mkIf cfg.enable {
    qqNumber = {
      owner = cfg.user;
      group = cfg.group;
      mode = "0400";
    };
  };
  services.quasique = {
    enable = false;
    qqPath = secrets.qqNumber.path;
  };

  topology.self = lib.mkIf cfg.enable {
    services.napcat = {
      name = "NapCat";
      info = "qq.estin.space";
      # no need to show listen address
      details = lib.mkForce { };
    };
  };
}
