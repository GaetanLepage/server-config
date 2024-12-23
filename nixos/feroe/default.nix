{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
    ./jellyfin.nix
    ./wireguard

    ../common/default.nix
  ];

  networking = {
    hostName = "feroe";

    # Needed for ZFS
    # generated using `head -c 8 /etc/machine-id`
    hostId = "02fa145d";
  };

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBSFYOqETOI1WDbKieqGIz5iHzys9n92eo/KBhPHeJh";

  # ZFS
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [ "backup_pool" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  ###################
  # ZFS replication #
  ###################
  environment.systemPackages = [ pkgs.lz4 ];

  users.users.zfs = {
    isNormalUser = true;

    # Can be ssh-ed with 'rsa_server'
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../common/zfs/ssh-key-server.pub)
    ];
  };
}
