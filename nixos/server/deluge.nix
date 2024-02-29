{config, ...}: let
  seedingPorts = [16881 6881];
in {
  age.secrets.deluge_auth_file = {
    file = ../../agenix/deluge_auth_file.age;
    owner = config.services.deluge.user;
    inherit (config.services.deluge) group;
  };

  users.users.gaetan.extraGroups = [
    config.services.deluge.group
  ];

  networking.firewall = {
    allowedTCPPorts = seedingPorts;
    allowedUDPPorts = seedingPorts;
  };

  services = {
    caddy.virtualHosts."deluge.glepage.com".extraConfig = ''
      import vpn
      reverse_proxy @vpn localhost:${toString config.services.deluge.web.port}
    '';

    deluge = {
      enable = true;

      declarative = true;
      authFile = config.age.secrets.deluge_auth_file.path;

      web.enable = true;

      config = {
        download_location = "/tank/tmp/deluge";
        max_active_downloading = 20;
        max_active_limit = 200;

        # random_port = false;
        listen_random_port = false;
        listen_ports = seedingPorts;
        max_active_seeding = 200;
        max_upload_slots_global = 200;
      };
    };
  };
}
