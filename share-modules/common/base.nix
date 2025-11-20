{
  time.timeZone = "Asia/Shanghai";

  # from whonix
  environment.etc.machine-id.text = "b08dfa6083e7567a1921a715000001fb";

  programs.command-not-found.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };
}
