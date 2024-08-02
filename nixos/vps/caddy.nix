let
  domain_name = "glepage.com";
in {
  # Open HTTP and HTTPS ports
  networking.firewall.allowedTCPPorts = [80 443];

  users.users.gaetan.extraGroups = ["caddy"];

  services.caddy = {
    enable = true;

    extraConfig = ''
      (vpn) {
          @vpn remote_ip 10.10.10.0/24
      }
    '';
  };
}
