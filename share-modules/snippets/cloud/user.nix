{
  pkgs,
  ...
}:

{
  programs.fish.enable = true;

  users.users =
    let
      hashedPassword = "$y$j9T$gXdOLmDCxnjtgvBkx9gQo0$j0LG4JYtPJPMiLhYEXicn6aXVGAn40S.Ehh6hT.PGm1";
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
