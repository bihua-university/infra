{
  inputs,
  ...
}:

{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
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

            nodes.cosimo = {
              interfaces = {
                tailscale0 = {
                  network = "tailscale";
                  # renderer.hidePhysicalConnections = true;
                  physicalConnections = [
                    (tlib.mkConnection "sheepro" "tailscale0")
                  ];
                };
              };
            };
            nodes.sheepro = {
              interfaces = {
                tailscale0.network = "tailscale";
              };
            };

            nodes.outer-space = {
              deviceType = "device";
              services = {
                livehouse = {
                  name = "alisten";
                  info = "livehouse.bhu.social";
                  icon = pkgs.fetchurl {
                    url = "https://livehouse.bhu.social/icon-180x180.png";
                    sha256 = "sha256-9zFpSFsE8kIduTPiODH8cTkLvgfCnQ+eeQxVU21bk08=";
                  };
                };
              };
            };
          }
        )
      ];
    };
}
