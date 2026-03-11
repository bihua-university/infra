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

  sops.secrets.qqNumber = {
    owner = cfg.user;
    group = cfg.group;
    mode = "0400";
  };
  services.quasique = {
    enable = true;
    qqPath = secrets.qqNumber.path;
  };

  services.caddy.virtualHosts = lib.mkIf cfg.enable {
    "qq.bhu.social".extraConfig = ''
      import tsnet
      reverse_proxy http://sheepro:${toString cfg.port} {
        header_down X-Real-IP {http.request.remote}
        header_down X-Forwarded-For {http.request.remote}
      }
    '';
  };

  topology.self = lib.mkIf cfg.enable {
    services.napcat = {
      info = "qq.bhu.social";
      # no need to show listen address
      details = lib.mkForce { };
    };
  };
}
