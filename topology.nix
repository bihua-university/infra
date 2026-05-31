{
  inputs,
  ...
}:

{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem =
    { pkgs, lib, ... }:
    {
      topology.modules = [
        (
          { config, ... }:
          let
            tlib = config.lib.topology;
            optimized-Guix-head = pkgs.callPackage ./pkgs/optimize-svg.nix {
              inherit pkgs;
              src = pkgs.fetchurl {
                url = "https://codeberg.org/guix/artwork/raw/commit/c75386b19003085c493ee54f7002584c570455dd/logo/head-only/Guix-head.svg";
                sha256 = "sha256-nNy6ZvNZtxoMHIB3RCPyYCQrUj8u+9eWEisWwkifJlg=";
              };
            };
          in
          {
            icons.devices.guix.file = optimized-Guix-head;

            nodes.internet = tlib.mkInternet {
              connections = tlib.mkConnection "herb" "ppp0";
            };
            networks.tailscale = {
              name = "Tailscale Net";
              cidrv4 = "100.64.0.0/10";
              style = {
                primaryColor = "#f1cf8a";
                secondaryColor = "#111111";
                pattern = "dashed";
              };
              icon = "interfaces.wireguard";
            };

            nodes.cosimo = {
              interfaces = {
                tailscale0 = {
                  network = "tailscale";
                  # renderer.hidePhysicalConnections = true;
                  physicalConnections = [
                    (tlib.mkConnection "sheepro" "tailscale0")
                  ];
                  virtual = true;
                };
              };
            };
            nodes.sheepro = {
              interfaces = {
                tailscale0 = {
                  network = "tailscale";
                  virtual = true;
                };
              };
            };

            nodes.outer-space = {
              deviceType = "device";
              deviceIcon = "devices.cloud-server";
              services = {
                livehouse = {
                  name = "alisten";
                  info = "livehouse.2jk.pw";
                  icon = pkgs.fetchurl {
                    url = "https://livehouse.2jk.pw/icon-180x180.png";
                    sha256 = "sha256-9zFpSFsE8kIduTPiODH8cTkLvgfCnQ+eeQxVU21bk08=";
                  };
                };
              };
            };
            nodes.herb = {
              deviceType = "device";
              deviceIcon = "devices.guix";
              hardware.info = "NanoPi R2S";
              interfaces = {
                tailscale0 = {
                  network = "tailscale";
                  physicalConnections = [
                    (tlib.mkConnection "cosimo" "tailscale0")
                    (tlib.mkConnection "sheepro" "tailscale0")
                  ];
                  virtual = true;
                };
                ppp0 = { };
              };
              services = {
                caddy = {
                  name = "Caddy";
                  icon = "services.caddy";
                };
              };
            };
          }
        )
      ];
    };
}
