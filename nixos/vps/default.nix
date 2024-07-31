{lib, ...}:
{
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

  boot.loader.systemd-boot.enable = lib.mkForce false;
}
