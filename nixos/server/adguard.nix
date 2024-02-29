let
  port = 1080;
in {
  networking.firewall.allowedTCPPorts = [53];

  services = {
    caddy.virtualHosts."adguard.glepage.com".extraConfig = ''
      import vpn
      reverse_proxy @vpn localhost:${toString port}
    '';

    adguardhome = {
      enable = true;

      settings = {
        users = [
          {
            name = "admin";
            # bcrypt-encrypted password
            # generated using `nix-shell -p apacheHttpd --command "htpasswd -bnBC 10 '' PASSWORD | tr -d ':'"`
            password = "$2y$10$jFtWc1kUB0Xebs6Pm5nlTOcxABdpdANSEStGp95cJN253PgIBILQ6";
          }
        ];

        http = {
          address = "0.0.0.0:${builtins.toString port}";
          session_ttl = "720h";
        };

        dns = {
          bind_hosts = ["0.0.0.0"];

          bootstrap_dns = ["9.9.9.9"];
        };
      };

      mutableSettings = false;
    };
  };
}
