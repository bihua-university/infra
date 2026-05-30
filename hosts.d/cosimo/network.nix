{
  lib,
  config,
  ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking.nameservers = [
    "223.5.5.5"
    "1.1.1.1"
    "9.9.9.9"
  ];

  services.openssh = {
    ports = lib.mkForce [ 2234 ];
    extraConfig = ''
      Match User agent
          PasswordAuthentication yes
    '';
  };
  users.users.agent = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$N7AB4g6SZp0izyy.wXLee0$TLM.QeNAtl7wYVnGIT4GehDdmvqYJoITInz9/N3J9a3";
  };
  security.pam.services.sshd.unixAuth = lib.mkForce true;

  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    openFirewall = true; # default port: 41641
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--ssh"
      "--relay-server-port=40004"
    ];
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
  networking.firewall.allowedUDPPorts = [ 40004 ];
}
