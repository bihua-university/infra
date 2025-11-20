toplevel@{
  withSystem,
  self,
  inputs,
  lib,
  ...
}:

let
  inherit (builtins) mapAttrs;

  cfg = toplevel.config.infra;

  hostModule = lib.types.submodule {
    options = {
      system = lib.mkOption {
        type = lib.types.enum toplevel.config.systems;
      };
      directory = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  mkNixOS =
    hostname:
    { system, directory }:
    (withSystem system (
      { inputs', ... }:
      let
        inherit (toplevel.config.flake) overlays legacyNixosModules;
      in
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          flake = {
            inherit
              self
              inputs
              inputs'
              overlays
              ;
            inherit (toplevel) config;
          };
          modules = legacyNixosModules;
        };
        modules =
          # import common module for all NixOS
          (builtins.attrValues legacyNixosModules.common) ++ [
            {
              imports = lib.collect (v: !(lib.isAttrs v)) (
                lib.packagesFromDirectoryRecursive {
                  callPackage = path: _: path;
                  inherit directory;
                }
              );
            }
            {
              nixpkgs = {
                hostPlatform = system;
                overlays = [
                  overlays.default
                  inputs.deploy-rs.overlays.default
                ];
              };
              networking.hostName = lib.mkForce hostname;
            }
          ];
      }
    ));

  deployLib = inputs.deploy-rs.lib;
  mkNode =
    _name: nixosConfiguration:
    let
      hostname = nixosConfiguration.config.networking.hostName;
      inherit (nixosConfiguration.config.nixpkgs.hostPlatform) system;
    in
    {
      inherit hostname;
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.${system}.activate.nixos nixosConfiguration;
      };
    };
in
{
  _class = "flake";

  options.infra = {
    hosts = lib.mkOption {
      type = lib.types.attrsOf hostModule;
      default = { };
    };
    share-module = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
    };
  };

  config = {
    flake.nixosConfigurations = mapAttrs mkNixOS cfg.hosts;

    flake.nixosModules = toplevel.config.flake.legacyNixosModules;
    flake.legacyNixosModules = lib.mkIf (cfg.share-module != null) (
      lib.packagesFromDirectoryRecursive {
        callPackage = path: _: import path;
        directory = cfg.share-module;
      }
    );

    # deploy-rs
    flake.deploy = {
      fastConnection = true;
      nodes = mapAttrs mkNode toplevel.config.flake.nixosConfigurations;
    };
  };
}
