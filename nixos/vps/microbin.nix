{config, ...}: {
  services = {
    caddy.virtualHosts."paste.glepage.com".extraConfig = ''
      reverse_proxy localhost:${toString config.services.microbin.settings.MICROBIN_PORT}
    '';

    microbin = {
      enable = true;
      settings = {
        MICROBIN_ETERNAL_PASTA = true;
      };
    };
  };
}
