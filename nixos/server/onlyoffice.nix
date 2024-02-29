let
  domain = "onlyoffice.glepage.com";
  port = "1680";
in {
  nixpkgs.config.allowUnfree = true;

  services = {
    caddy.virtualHosts."${domain}".extraConfig = ''
      reverse_proxy localhost:${port}
    '';
  };

  virtualisation = {
    podman = {
      enable = true;
    };

    oci-containers.containers.only-office = {
      image = "onlyoffice/documentserver";
      ports = ["${port}:80"];
      # Disable token authentication because it is annoying...
      environment.JWT_ENABLED = "false";
    };
  };
}
