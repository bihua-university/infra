{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;
in
{
  sops.secrets = lib.mkIf cfg.caddy.enable {
    caddy = {
      sopsFile = flake.commonSecrets + /caddy.env;
      format = "dotenv";
    };
  };

  services.caddy = {
    enable = cfg.caddy.virtualHosts != { };
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
      hash = "sha256-RLOwzx7+SH9sWVlr+gTOp5VKlS1YhoTXHV4k6r5BJ3U=";
    };
    environmentFile = secrets.caddy.path;
    virtualHosts."(tsnet)".extraConfig = ''
      @blocked not remote_ip 100.64.0.0/10

      tls {
        dns cloudflare {$CLOUDFLARE_API_TOKEN}
      }

      respond @blocked "Unauthorized" 403
    '';
  };

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.caddy.enable [
    80
    443
  ];
}
