{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";

      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_rmem" = "8192 262144 1073741824";
      "net.ipv4.tcp_wmem" = "4096 16384 1073741824";
      "net.ipv4.tcp_adv_win_scale" = -2;

      "net.ipv6.tcp_congestion_control" = "bbr";
      "net.ipv6.tcp_rmem" = "8192 262144 1073741824";
      "net.ipv6.tcp_wmem" = "4096 16384 1073741824";
      "net.ipv6.route.mtu_expires" = 600;
      "net.ipv6.tcp_mtu_probing" = 1;

      # podman: https://github.com/jemalloc/jemalloc/issues/1328
      # "vm.overcommit_memory" = 1;
    };

    initrd = {
      # for preservation
      systemd.enable = true;
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_blk"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader.systemd-boot = {
      enable = true;
    };
  };

  networking.useDHCP = lib.mkDefault true;

  system.stateVersion = "24.05";
}
