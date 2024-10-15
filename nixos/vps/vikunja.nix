{config, ...}: let
  domain = "board.glepage.com";
in {
  services = {
    caddy.reverseProxies.${domain} = {
      inherit (config.services.vikunja) port;
    };

    vikunja = {
      enable = true;
      frontendScheme = "https";
      frontendHostname = domain;
    };
  };
}
