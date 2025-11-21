{
  config,
  ...
}:

let
  inherit (config.sops) secrets;
in
{
  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    openFirewall = true; # default port: 41641
    useRoutingFeatures = "server";
    extraSetFlags = [ "--relay-server-port=40004" ];
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
  networking.firewall.allowedUDPPorts = [ 40004 ];
}
