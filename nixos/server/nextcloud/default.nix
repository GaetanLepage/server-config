{
  config,
  pkgs,
  ...
}: let
  hostname = "cloud.glepage.com";

  databaseName = "nextcloud";
in {
  imports = [
    ./onlyoffice.nix
  ];

  age.secrets.nextcloud-secret-file = {
    rekeyFile = ./nextcloud-secret-file.age;
    owner = "nextcloud";
    group = "nextcloud";
  };

  users.users.caddy.extraGroups = ["nextcloud"];

  services = {
    ##############
    # Web server #
    ##############

    # Using caddy --> We have to manually disable nginx.
    nginx.enable = false;

    phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };

    caddy.virtualHosts.${hostname} = {
      extraConfig = ''
        root * ${config.services.nextcloud.package}
        file_server

        php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket}

        header {
            # enable HSTS
            Strict-Transport-Security max-age=31536000;
        }

        # Apps paths
        handle /nix-apps/* {
            root * ${config.services.nextcloud.home}
        }
        handle /store-apps/* {
            root * ${config.services.nextcloud.home}
        }

        redir /.well-known/carddav /remote.php/dav 301
        redir /.well-known/caldav /remote.php/dav 301

        # .htaccess / data / config / ... shouldn't be accessible from outside
        @forbidden {
            path    /.htaccess
            path    /data/*
            path    /config/*
            path    /db_structure
            path    /.xml
            path    /README
            path    /3rdparty/*
            path    /lib/*
            path    /templates/*
            path    /occ
            path    /console.php
        }

        respond @forbidden 404
      '';
    };

    ############
    # Database #
    ############

    postgresql = {
      enable = true;
      ensureDatabases = [databaseName];
      ensureUsers = [
        {
          name = databaseName;
          ensureDBOwnership = true;
        }
      ];
    };

    #############
    # Nextcloud #
    #############

    nextcloud = {
      enable = true;

      package = pkgs.nextcloud28;

      hostName = hostname;

      # Use HTTPS for links
      https = true;

      datadir = "/tank/nextcloud";
      autoUpdateApps.enable = true;
      appstoreEnable = true;
      extraApps = {
        inherit
          (config.services.nextcloud.package.packages.apps)
          calendar
          contacts
          cospend
          tasks
          ;
      };

      # https://docs.nextcloud.com/server/27/admin_manual/configuration_files/files_locking_transactional.html
      configureRedis = true;

      secretFile = config.age.secrets.nextcloud-secret-file.path;

      config = {
        adminpassFile = "/var/nextcloud_admin_pass";
        adminuser = "glepage";

        # Database
        dbtype = "pgsql";
        dbuser = databaseName;
        dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = databaseName;
      };

      settings = {
        trusted_proxies = ["localhost"];

        # Further forces Nextcloud to use HTTPS
        overwriteprotocol = "https";

        default_phone_region = "FR";

        # https://github.com/NixOS/nixpkgs/issues/192400
        "integrity.check.disabled" = true;

        "opcache.interned_strings_buffer" = 32;
      };
    };
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
