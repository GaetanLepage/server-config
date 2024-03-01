{
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "github:GaetanLepage/server-config";
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
    ];
    allowReboot = true;
  };

  # Enable flake support
  nix = {
    settings = {
      experimental-features = "nix-command flakes";

      warn-dirty = false;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "05:00";
      options = "--delete-older-than 4d";
    };
  };
}
