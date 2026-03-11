{
  pkgs,
  ...
}:

{
  programs.fish.enable = true;

  users.users =
    let
      hashedPassword = "$y$j9T$621h14vfEZnHDa.acfUG7.$5bJQ52EkMpTeiPvJ.ldLCdwAMxpWGF1D4cVLF34n997";
    in
    {
      bhu = {
        isNormalUser = true;
        home = "/home/bhu";
        description = "BHU";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "audio"
          "networkmanager"
        ];
        inherit hashedPassword;
        hashedPasswordFile = null;
      };
      root = {
        inherit hashedPassword;
        hashedPasswordFile = null;
      };
    };
}
