{lib, ...}: let
  port = "8081";
in {
  services.caddy.virtualHosts."photos.glepage.com".extraConfig = ''
    reverse_proxy localhost:${port}
  '';

  virtualisation = {
    podman.enable = true;

    oci-containers.containers.pigallery2 = {
      image = "bpatrik/pigallery2:latest";
      ports = ["${port}:80"];
      environment.NODE_ENV = "production";
      volumes = let
        root = "/var/lib/pigallery2";
      in
        lib.mapAttrsToList (n: v: n + ":" + v) {
          "/tank/gaetan/photos" = "/app/data/images";
          "${root}/config" = "/app/data/config";
          "${root}/db" = "/app/data/db";
          "${root}/tmp" = "/app/data/tmp";
        };
    };
  };
}
