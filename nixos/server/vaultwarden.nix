{config, ...}: let
  port = 1380;
  domain = "bitwarden.glepage.com";
in {
  age.secrets.vaultwarden_env_file.file = ../../agenix/vaultwarden_env_file.age;

  services = {
    caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';

    vaultwarden = {
      enable = true;

      backupDir = "/tank/backup/vaultwarden";

      environmentFile = config.age.secrets.vaultwarden_env_file.path;

      config = {
        DOMAIN = "https://${domain}";

        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = port;

        ROCKET_LOG = "critical";

        # This example assumes a mailserver running on localhost,
        # thus without transport encryption.
        # If you use an external mail server, follow:
        #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
        SMTP_HOST = "127.0.0.1";
        SMTP_PORT = 25;
        SMTP_SSL = false;

        SMTP_FROM = "bitwarden@glepage.com";
        SMTP_FROM_NAME = "glepage.com Bitwarden server";
      };
    };
  };
}
