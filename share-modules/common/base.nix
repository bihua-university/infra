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
    extraGroups = [ "wheel" ];
  };
  users.groups.deploy = { };

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        users = [ "deploy" ];
        runAs = "root";
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
