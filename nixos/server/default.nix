{
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix

    ../common/default.nix

    # System
    ./backup.nix
    ./users.nix
    ./zfs.nix

    # Email
    ./mailserver.nix
    ./webmail.nix

    # File sharing
    ./nfs.nix
    ./samba.nix

    # Web server
    ./caddy.nix

    # Database
    ./postgresql.nix

    # Services
    ./adguard.nix
    ./deluge
    ./dolibarr.nix
    ./hedgedoc.nix
    ./inria.nix
    ./invidious.nix
    ./nextcloud.nix
    ./onlyoffice.nix
    ./vaultwarden
    ./wireguard
  ];

  networking = {
    hostName = "server";

    # Needed for ZFS
    # generated using `head -c 8 /etc/machine-id`
    hostId = "4ce2e691";
  };

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKe9Aaq7KTHGkw3eMK8Qv/NkzAW0hvRzFQQ6Qxu6U3Jk";

  services.nginx.enable = lib.mkForce false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Network
    lsof
    wol
    dig

    # Monitoring
    btop
    htop

    # Misc
    czkawka
    lf
    ncdu
    ripgrep
    fd
    tree
    unzip
    wget
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
