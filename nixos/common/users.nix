{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;

    users =
      let
        laptopRsaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJSonNBBb1DlhaO4EfMh3TbIIsV25phZQ9vp/qKOw9E";
      in
      {
        root = {
          isSystemUser = true;

          hashedPassword = "$6$CVY8DuUDlFoCerDi$iIsPGrjWocBgBew4MvdMz.9LYx.lIwBm1LFOktd6TqYAFroKdvCKKpbB1uu2mQsgYEx1ANfArlsh2hl1WfHhE.";

          openssh.authorizedKeys.keys = [ laptopRsaKey ];
        };

        gaetan = {
          isNormalUser = true;

          group = "gaetan";

          # Enable ‘sudo’ for the user.
          extraGroups = [ "wheel" ];

          hashedPassword = "$6$ZlZfQDSTcu910hPC$VR/toXj.YLDSe3MkSL7vYI/3U4t89lqsaNZXE4LnantFmxCuEiuhIXGWXtzcxQxO0hV/m/LApQu.ehfPbupS71";

          openssh.authorizedKeys.keys = [ laptopRsaKey ];
        };
      };

    groups.gaetan = {
      gid = 1000;
      members = [ "gaetan" ];
    };
  };
}
