let
  domain_name = "glepage.com";
in {
  networking = {
    # Open HTTP and HTTPS ports
    firewall.allowedTCPPorts = [80 443];

    # Services that are only accessible from the vpn
    hosts = {
      "10.10.10.1" = [
        "adguard.${domain_name}"
        "deluge.${domain_name}"
        "router.${domain_name}"
        "tensorboard.${domain_name}"
      ];
    };
  };

  users.users.gaetan.extraGroups = ["caddy"];

  services.caddy = {
    enable = true;

    extraConfig = ''
      (vpn) {
          @vpn {
              remote_ip 10.10.10.0/24
          }
      }
    '';

    virtualHosts = {
      # Router configuration
      "router.${domain_name}".extraConfig = ''
        import vpn

        handle @vpn {
            reverse_proxy {
                to 192.168.1.1:443
                transport http {
                    tls
                    tls_insecure_skip_verify
                }
            }
        }
      '';

      # Box configuration
      "box.${domain_name}".extraConfig = ''
        reverse_proxy http://192.168.100.1
      '';

      "${domain_name}".extraConfig = ''
        handle_path /df {
            redir https://github.com/GaetanLepage/nix-config
        }

        root * /var/www/personal_website/
        encode gzip

        file_server browse
      '';

      "jellyfin.${domain_name}".extraConfig = ''
        reverse_proxy 10.10.10.23:8096
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
