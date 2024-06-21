{config, ...}: {
  services = let
    poolName = config.services.selfoss.pool;

    caddyUser = config.services.caddy.user;
    caddyGroup = config.services.caddy.group;
  in {
    caddy.virtualHosts."rss.glepage.com".extraConfig = ''
      import vpn

      php_fastcgi unix/${config.services.phpfpm.pools.${poolName}.socket}

      root * /var/lib/selfoss

      file_server browse
    '';
    # encode gzip
    # handle @vpn {
    # }

    phpfpm.pools.${poolName}.settings = {
      user = caddyUser;
      group = caddyGroup;
      "listen.owner" = caddyUser;
      "listen.group" = caddyGroup;
    };

    selfoss = {
      enable = true;
      user = caddyUser;
    };
  };
}
