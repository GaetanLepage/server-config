{config, ...}: {
  age.secrets.photoprism-password.rekeyFile = ./password.age;

  services = let
    hostname = "photos.glepage.com";
  in {
    caddy.virtualHosts.${hostname}.extraConfig = ''
      reverse_proxy localhost:${toString config.services.photoprism.port}
    '';

    photoprism = {
      enable = true;

      settings = {
        PHOTOPRISM_SITE_URL = "https://${hostname}";
        PHOTOPRISM_READONLY = "true";
        PHOTOPRISM_DISABLE_SETTINGS = "true";
        PHOTOPRISM_DISABLE_WEBDAV = "true";
      };

      originalsPath = "/tank/gaetan/photos";
      importPath = "/var/lib/photoprism/import";
      passwordFile = config.age.secrets.photoprism-password.path;
    };
  };
}
