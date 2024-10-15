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

      "jellyfin.${domain_name}".extraConfig = ''
        reverse_proxy 10.10.10.23:8096
      '';
    };
  };
}
