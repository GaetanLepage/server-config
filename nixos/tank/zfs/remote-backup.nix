{
  config,
  pkgs,
  ...
}:
{
  age.secrets.zfs-remote-backup-ssh-key.rekeyFile = ./ssh-key.age;

  services.zfs.autoReplication = {
    enable = true;

    package =
      let
        pkgs-master = import (fetchTarball {
          url = "https://github.com/GaetanLepage/nixpkgs/archive/dde261fe0fb557f98c416bfcdf8bc9c4c69b6241.tar.gz";
          sha256 = "11kph768mx0mr5pzh9r5bfq2yywapbfdsd329mryyaibwxd0hgq2";
        }) { inherit (pkgs.stdenv) system; };
      in
      pkgs-master.zfs-replicate;

    localFilesystem = "tank";

    identityFilePath = config.age.secrets.zfs-remote-backup-ssh-key.path;

    host = "10.10.10.23";
    username = "zfs";
    remoteFilesystem = "backup_pool/tank_backup";
  };

  programs.ssh.knownHosts.${config.services.zfs.autoReplication.host}.publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBSFYOqETOI1WDbKieqGIz5iHzys9n92eo/KBhPHeJh";
}
