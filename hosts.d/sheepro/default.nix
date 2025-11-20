{
  modules,
  ...
}:

{
  imports = with modules.snippets.cloud; [
    user
    ssh
    optimization
  ];

  networking.proxy.default = "http://192.168.114.1:8080";

  # manage hostname through nix options
  proxmoxLXC.manageHostName = true;
}
