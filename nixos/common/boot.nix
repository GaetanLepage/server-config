{
  boot = {
    # Enable zfs support
    supportedFilesystems = ["zfs"];

    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 4;
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
