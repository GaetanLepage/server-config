let
  hostname = "adguard.glepage.com";
  port = 1080;
in {
  networking = {
    hosts = {
      "10.10.10.1" = [
        hostname
        "tensorboard.glepage.com"
      ];
      "10.10.10.8" = [
        "deluge.glepage.com"
        "router.glepage.com"
      ];
    };
    firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };

  services = {
    caddy.virtualHosts.${hostname}.extraConfig = ''
      import vpn
      reverse_proxy @vpn localhost:${toString port}
    '';

    adguardhome = {
      enable = true;

      inherit port;

      settings = {
        users = [
          {
            name = "admin";
            # bcrypt-encrypted password
            # generated using `nix-shell -p apacheHttpd --command "htpasswd -bnBC 10 '' PASSWORD | tr -d ':'"`
            password = "$2y$10$jFtWc1kUB0Xebs6Pm5nlTOcxABdpdANSEStGp95cJN253PgIBILQ6";
          }
        ];

        http.session_ttl = "720h";

        dns = {
          bind_hosts = ["0.0.0.0"];

          bootstrap_dns = ["9.9.9.9"];
        };
      };

      mutableSettings = false;
    };
  };
}
