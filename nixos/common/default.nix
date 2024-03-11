{
  imports = [
    ./agenix.nix
    ./boot.nix
    ./nix.nix
    ./programs.nix
    ./ssh.nix
    ./users.nix
  ];

  networking = {
    # Pick only one of the below networking options.
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.

    firewall.enable = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus13";
    keyMap = "fr";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # LVS (fwupd)
  services.fwupd.enable = true;
}
