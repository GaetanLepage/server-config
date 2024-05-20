{
  pkgs,
  config,
  ...
}: let
  db-name = "dolibarr";

  inherit config;
in {
  services = {
    ##############
    # Web server #
    ##############
    caddy.virtualHosts."dolibarr.lepage-knives.com".extraConfig = ''
      root * /var/www/dolibarr/htdocs
      file_server
      encode gzip

      php_fastcgi unix/${config.services.phpfpm.pools.dolibarr.socket}
    '';

    ###########
    # Php FPM #
    ###########
    phpfpm.pools.dolibarr = {
      user = "dolibarr";
      group = "dolibarr";

      # (2024-01-10) When trying to upgrade to dolibarr 18.0.4, I got:
      # > PHP version too high. Version 8.1.0 or lower is required.
      phpPackage = pkgs.php81;

      settings = {
        "listen.owner" = config.services.caddy.user;
        "listen.group" = config.services.caddy.group;

        "pm" = "dynamic";
        "pm.max_children" = "32";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "2";
        "pm.max_spare_servers" = "4";
        "pm.max_requests" = "500";
      };
    };

    ############
    # Database #
    ############
    mysql = {
      enable = true;
      package = pkgs.mariadb;

      ensureDatabases = [db-name];
      ensureUsers = [
        {
          # The user has the same name as the database
          name = db-name;
          ensurePermissions."${db-name}.*" = "ALL PRIVILEGES";
        }
      ];
    };
    mysqlBackup = {
      enable = true;
      databases = [db-name];
    };
  };

  users = {
    users.dolibarr = {
      group = "dolibarr";
      isSystemUser = true;
    };

    groups.dolibarr.members = [
      config.services.caddy.user
    ];
  };
}
