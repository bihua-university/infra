{
  inputs,
  ...
}:

{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem = {
    topology.modules = [
      (
        { config, ... }:
        let
          tlib = config.lib.topology;
        in
        {
          networks.tailscale = {
            name = "Tailscale Net";
            cidrv4 = "100.64.0.0/10";
          };

          nodes.internet-at-jdcloud = tlib.mkInternet {
            connections = tlib.mkConnection "cosimo" "ens5";
          };
          nodes.internet-at-mie = tlib.mkInternet {
            connections = tlib.mkConnection "sheepro" "eth0@if62";
          };

          nodes.cosimo = {
            interfaces = {
              tailscale0 = {
                network = "tailscale";
                physicalConnections = [
                  (tlib.mkConnection "sheepro" "tailscale0")
                ];
              };
              ens5 = { };
            };
          };
          nodes.sheepro = {
            interfaces = {
              "eth0@if62" = { };
            };
          };
        }
      )
    ];
  };
}
