{ pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";
  documentation = {
    doc.enable = false;
    man.enable = false;
  };

  # from whonix
  environment.etc.machine-id.text = "b08dfa6083e7567a1921a715000001fb";
  programs.command-not-found.enable = false;

  users.users.deploy = {
    isNormalUser = true;
    group = "deploy";
    home = "/var/lib/deploy";
    shell = pkgs.bash;
    description = "Deployment user for CI/CD";
  };
  users.groups.deploy = { };

  # NOTE: from sudo-rs SUDOERS(5)
  # Wildcards in command line arguments are not supported—using these in original versions of sudo was usually a sign
  # of mis-configuration and consequently sudo-rs simply forbids using them.
  # no need to do this acctually...the hosts behind tailscale ACL
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
    # Deploy user passwordless sudo for deploy-rs commands
    extraRules =
      let
        mkDeployRule = command: {
          users = [ "deploy" ];
          runAs = "root";
          commands = [
            {
              inherit command;
              options = [ "NOPASSWD" ];
            }
          ];
        };
      in
      [
        (mkDeployRule "/run/current-system/bin/switch-to-configuration")
        (mkDeployRule "/nix/store/*/activate-rs activate *")
        (mkDeployRule "/nix/store/*/activate-rs wait *")
        (mkDeployRule "/run/current-system/sw/bin/rm /tmp/deploy-rs*")
      ];
  };
}
