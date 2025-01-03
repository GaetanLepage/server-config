{
  config,
  pkgs-unstable,
  ...
}:
{
  age.secrets.zfs-remote-backup-ssh-key.rekeyFile = ./ssh-key.age;

  services.zfs.autoReplication = {
    enable = true;

    # The lz4 fix cannot be backported to 24.11
    # TODO: remove when updating to 25.05
    # https://github.com/NixOS/nixpkgs/pull/370241
    package = pkgs-unstable.zfs-replicate;

    localFilesystem = "tank";

    identityFilePath = config.age.secrets.zfs-remote-backup-ssh-key.path;

    host = "10.10.10.23";
    username = "zfs";
    remoteFilesystem = "backup_pool/tank_backup";
  };

  programs.ssh.knownHosts.${config.services.zfs.autoReplication.host}.publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBSFYOqETOI1WDbKieqGIz5iHzys9n92eo/KBhPHeJh";
}
