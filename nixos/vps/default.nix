{lib, ...}: {
  imports = [
    ./disko.nix
    ./hardware.nix
    # ./nix.nix
    # ./ssh.nix
    # ./users.nix

    ../common/default.nix
  ];

  system.stateVersion = "24.05";

  networking.hostName = "vps";

  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1Oy9/d0KtPZSf1bhJjItykOJEz43uPLNpYPdJ8bd8x";

  boot.loader.systemd-boot.enable = lib.mkForce false;
}
