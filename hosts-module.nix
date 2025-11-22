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
        inherit (toplevel.config.flake) legacyNixosModules;
      in
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          flake = {
            inherit
              self
              inputs
              inputs'
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
                inherit (cfg) overlays;
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
      suffix = lib.optionalString (cfg.tsnet != null) ".${cfg.tsnet}";
      inherit (nixosConfiguration.config.nixpkgs.hostPlatform) system;
    in
    {
      hostname = "${hostname}${suffix}";
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
    tsnet = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
    share-module = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
    };
    overlays = lib.mkOption {
      type = with lib.types; listOf (functionTo (functionTo attrs));
      default = [
        toplevel.config.flake.overlays.default
        inputs.deploy-rs.overlays.default
      ];
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
