{
  config,
  pkgs,
  ...
}: {
  age.secrets.wireguard_server_private_key.file = ../../agenix/wireguard_server_private_key.age;

  networking = let
    external_interface = "eno1";
    port = 51820;
  in {
    # Open ports
    firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53 port];
    };

    # enable NAT
    nat = {
      enable = true;
      externalInterface = external_interface;
      internalInterfaces = ["wg0"];
    };

    wireguard.interfaces.wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = ["10.10.10.1/24"];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = port;

      # This allows the wireguard server to route your traffic to the internet and hence be
      # like a VPN.
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of
      # choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o ${external_interface} -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -o ${external_interface} -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      # privateKeyFile = "/etc/wireguard/wireguard_server_private_key";
      privateKeyFile = config.age.secrets.wireguard_server_private_key.path;
      # >>> PUBLIC KEY: jWzlVwkNkaO1uj7Qh+Xemo0EtxIYP2ufK+18oPcdvBY=

      # List of allowed peers.
      peers = [
        ##########
        # Gaetan #
        ##########

        # tuxedo laptop
        {
          publicKey = "OWezLnTrXzr1YFRs96urcqkOF6J+55S3c1NI0Jq4AXk=";
          allowedIPs = ["10.10.10.2/32"];
        }
        # Phone
        {
          publicKey = "01dWWmsHjpNH7vCEioE3RkSl71zBVM6iSG+Vbb4yix0=";
          allowedIPs = ["10.10.10.3/32"];
        }
        # alya
        {
          publicKey = "hwt8e4sb0IkcrIhe/IBkefZjpa9LcRp5OUoKs569nCY=";
          allowedIPs = ["10.10.10.4/32"];
        }
        # cuda
        {
          publicKey = "J+STSrQtKJQoUNykoVF3c9ngaVUkMO3FLefQjIX1qBw=";
          allowedIPs = ["10.10.10.5/32"];
        }

        #################
        # Lepage family #
        #################

        # ACL desktop
        {
          publicKey = "YWmfO36tHExpsxHR8E+i7YzW8XkKaJhbU9WLpoe08g8=";
          allowedIPs = ["10.10.10.20/32"];
        }

        # MacBook FL
        {
          publicKey = "h9/IH7UOiK0d9NXZ1liIsiJrQoSzJa5TqGFC0rQnKw0=";
          allowedIPs = ["10.10.10.21/32"];
        }

        # Laptop TL
        {
          publicKey = "sHlIzQ1NMKcTQfr30Ss+LtqbauBySpQN4+WvW5SOXXI=";
          allowedIPs = ["10.10.10.22/32"];
        }

        # Feroe
        {
          publicKey = "GXT4bebPRfYqR3cvODMZsR2GdCsldnAe6BnkMhI6rTs=";
          allowedIPs = ["10.10.10.23/32"];
        }
      ];
    };
  };
}
