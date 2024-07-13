{
  #########
  # Notes #
  #########
  # For a user to be authenticated on the samba server, you must add their password using
  # `smbpasswd -a <user>` as root.

  ########
  # WSDD #
  ########
  # make shares visible for windows 10 clients
  services.samba-wsdd.enable = true;
  networking.firewall = {
    allowedTCPPorts = [5357];
    allowedUDPPorts = [3702];
  };

  ################
  # samba server #
  ################
  services.samba = {
    enable = true;

    openFirewall = true;

    shares = {
      lepage = {
        path = "/tank/lepage_family/";
        public = "no";
        writable = "yes";
        "guest ok" = "no";
        "valid users" = ["anne-catherine" "lepage" "tanguy"];
      };

      share = {
        path = "/tank/share/";
        public = "yes";
        writable = "yes";
        "guest ok" = "yes";
      };
    };
  };
}
