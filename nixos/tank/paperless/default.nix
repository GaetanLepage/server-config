{ config, ... }:
let
  domain = "paperless.glepage.com";
in
{
  age.secrets.paperless-password-file.rekeyFile = ./paperless-password-file.age;
  services = {
    caddy.reverseProxies."${domain}".port = config.services.paperless.port;

    paperless = {
      enable = true;

      dataDir = "/tank/gaetan/paperless";
      # database.createLocally = true;
      passwordFile = config.age.secrets.paperless-password-file.path;

      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        # PAPERLESS_OCR_LANGUAGE = "fr+eng";
      };
    };
  };
}
