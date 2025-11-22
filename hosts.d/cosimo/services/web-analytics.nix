{
  config,
  lib,
  pkgs,
  ...
}:

let
  enable = true;

  cfg = config.services.goatcounter;
in
{
  services.goatcounter = {
    inherit enable;
    address = config.networking.hostName;
  };

  services.caddy.virtualHosts = lib.mkIf cfg.enable {
    "chat.bhu.social".extraConfig = ''
      import tsnet
      reverse_proxy http://${cfg.address}:${toString cfg.port} {
        header_down X-Real-IP {http.request.remote}
        header_down X-Forwarded-For {http.request.remote}
      }
    '';
  };

  topology.self = {
    services.goatcounter = {
      name = "GoatCounter";
      info = "analytics.bhu.social";
      icon = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/arp242/goatcounter/b8116268d211be3e05e7b63f58cad78724baf4ec/public/logo.svg";
        sha256 = "sha256-cEVZGb7ZRMo55m+3cd3JVml0Ij+zRsOnGJwnZsGJeuw=";
      };
    };
  };
}
