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

  security.sudo-rs = {
    enable = true;
    execWheelOnly = false;
    wheelNeedsPassword = true;
    extraRules = [
      {
        users = [ "deploy" ];
        commands = [
          {
            command = "/run/current-system/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
    extraConfig = ''
      # Deploy user passwordless sudo for deploy-rs commands
      deploy ALL=(ALL) NOPASSWD: /nix/var/nix/profiles/system/bin/activate-rs activate *
      deploy ALL=(ALL) NOPASSWD: /nix/var/nix/profiles/system/bin/activate-rs wait *
      deploy ALL=(ALL) NOPASSWD: /nix/store/*/bin/activate-rs activate *
      deploy ALL=(ALL) NOPASSWD: /nix/store/*/bin/activate-rs wait *
      deploy ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/rm /tmp/deploy-rs*
    '';
  };
}
