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

    virtualHosts = {
      "${domain_name}".extraConfig = ''
        handle_path /df {
            redir https://github.com/GaetanLepage/nix-config
        }

        root * /var/www/personal_website/
        encode gzip

        file_server browse
      '';

      # Grenug
      "www.grenug.fr".extraConfig = ''
        redir https://grenug.fr
      '';

      "grenug.fr".extraConfig = ''
        root * /var/www/grenug/
        encode gzip

        file_server browse
      '';
    };
  };
}
