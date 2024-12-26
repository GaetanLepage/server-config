{ config, ... }:
let
  remoteBackupHostname = "10.10.10.23";
in
{
  age.secrets.rsa_server.rekeyFile = ../common/zfs/ssh-key-server.age;

  # Enable zfs support
  boot.supportedFilesystems = [ "zfs" ];

  fileSystems = {
    "/tank" = {
      device = "tank";
      fsType = "zfs";
    };

    "/tank/tmp" = {
      device = "tank/tmp";
      fsType = "zfs";
    };
  };

  services.zfs = {
    autoScrub.enable = true;

    autoSnapshot = {
      enable = true;

      flags = "-k -p --utc";
    };

    autoReplication = {
      enable = true;

      localFilesystem = "tank";

      identityFilePath = config.age.secrets.rsa_server.path;

      host = remoteBackupHostname;
      username = "zfs";
      remoteFilesystem = "backup_pool/tank_backup";
    };
  };
  programs.ssh.knownHosts.${remoteBackupHostname}.publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBSFYOqETOI1WDbKieqGIz5iHzys9n92eo/KBhPHeJh";
}
