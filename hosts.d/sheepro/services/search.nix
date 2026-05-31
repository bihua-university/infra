{
  lib,
  config,
  ...
}:

let
  enable = true;

  cfg = config.services.websurfx;
in
{
  services.websurfx = {
    inherit enable;
    openFirewall = true;
    settings = {
      binding_ip = "100.64.83.119";
      port = 9001;
      # There will be a random delay before sending the request to the search engines if true
      production_use = true;
      # 0 - None
      # 1 - Low
      # 2 - Moderate
      # 3 - High
      # 4 - Aggressive
      safe_search = 0;
      proxy = config.networking.proxy.default;

      # unused
      http_cache_expiry_time = 60;
    };
  };
  services.redis = lib.mkIf cfg.enable {
    # The nixpkgs build doesn't have the redis-cache feature enabled
  };

  topology.self = lib.mkIf cfg.enable {
    services.websurfx = {
      name = "Websurfx";
      info = "search.estin.space";
      icon = "${cfg.package}/opt/websurfx/public/favicon/android-chrome-512x512.jpg";
    };
  };
}
