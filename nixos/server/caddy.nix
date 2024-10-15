let
  domain_name = "glepage.com";
in {
  # Open HTTP and HTTPS ports
  networking.firewall.allowedTCPPorts = [80 443];

  users.users.gaetan.extraGroups = ["caddy"];

  services.caddy = {
    enable = true;

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
    };
  };
}
