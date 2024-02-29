{pkgs, ...}: {
  networking = {
    # Pick only one of the below networking options.
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.

    firewall.enable = true;
  };

  age.rekey = {
    storageMode = "local";
    masterIdentities = [../../secrets/identity.age];
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;

    users = let
      laptopRsaKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJSonNBBb1DlhaO4EfMh3TbIIsV25phZQ9vp/qKOw9E";
    in {
      root = {
        isSystemUser = true;

        hashedPassword = "$6$CVY8DuUDlFoCerDi$iIsPGrjWocBgBew4MvdMz.9LYx.lIwBm1LFOktd6TqYAFroKdvCKKpbB1uu2mQsgYEx1ANfArlsh2hl1WfHhE.";

        openssh.authorizedKeys.keys = [laptopRsaKey];
      };

      gaetan = {
        isNormalUser = true;

        group = "gaetan";

        # Enable ‘sudo’ for the user.
        extraGroups = ["wheel"];

        hashedPassword = "$6$ZlZfQDSTcu910hPC$VR/toXj.YLDSe3MkSL7vYI/3U4t89lqsaNZXE4LnantFmxCuEiuhIXGWXtzcxQxO0hV/m/LApQu.ehfPbupS71";

        openssh.authorizedKeys.keys = [laptopRsaKey];
      };
    };

    groups.gaetan = {
      gid = 1000;
      members = ["gaetan"];
    };
  };

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;

      settings.PasswordAuthentication = false;
    };
  };

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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dua
    git
    htop
    tmux
  ];

  # Security
  environment.shellAliases.sudo = "doas";
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          groups = ["wheel"];
          persist = true;
        }
      ];
    };
  };

  programs = {
    ssh.startAgent = true;

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
