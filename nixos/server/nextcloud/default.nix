{
  config,
  pkgs,
  ...
}:
let
  hostname = "cloud.glepage.com";

  databaseName = "nextcloud";
in
{
  imports = [
    ./onlyoffice.nix
  ];

  age.secrets = {
    nextcloud-secret-file = {
      rekeyFile = ./nextcloud-secret-file.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    nextcloud-adminpass-file = {
      rekeyFile = ./nextcloud-adminpass-file.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  users.groups.nextcloud.members = [
    "nextcloud"
    config.services.caddy.user
  ];

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

    # Source: https://github.com/onny/nixos-nextcloud-testumgebung/blob/main/nextcloud-extras.nix#L117-L167
    caddy.virtualHosts.${hostname} =
      let
        webroot = config.services.nginx.virtualHosts.${hostname}.root;
      in
      {
        extraConfig = ''
          encode zstd gzip

          root * ${webroot}

          redir /.well-known/carddav /remote.php/dav 301
          redir /.well-known/caldav /remote.php/dav 301
          redir /.well-known/* /index.php{uri} 301
          redir /remote/* /remote.php{uri} 301

          header {
              Strict-Transport-Security max-age=31536000
              Permissions-Policy interest-cohort=()
              X-Content-Type-Options nosniff
              X-Frame-Options SAMEORIGIN
              Referrer-Policy no-referrer
              X-XSS-Protection "1; mode=block"
              X-Permitted-Cross-Domain-Policies none
              X-Robots-Tag "noindex, nofollow"
              -X-Powered-By
          }

          php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket} {
              root ${webroot}
              env front_controller_active true
              env modHeadersAvailable true
          }

          @forbidden {
              path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
              path /.* /autotest* /occ* /issue* /indie* /db_* /console*
              not path /.well-known/*
          }
          error @forbidden 404

          @immutable {
              path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
              query v=*
          }
          header @immutable Cache-Control "max-age=15778463, immutable"

          @static {
              path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
              not query v=*
          }
          header @static Cache-Control "max-age=15778463"

          @woff2 path *.woff2
          header @woff2 Cache-Control "max-age=604800"

          file_server
        '';
      };

    ############
    # Database #
    ############

    postgresql = {
      enable = true;
      ensureDatabases = [ databaseName ];
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

      package = pkgs.nextcloud30;

      hostName = hostname;

      # Use HTTPS for links
      https = true;

      datadir = "/tank/nextcloud";
      autoUpdateApps.enable = true;
      appstoreEnable = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          calendar
          contacts
          cospend
          onlyoffice
          ;
      };

      # https://docs.nextcloud.com/server/27/admin_manual/configuration_files/files_locking_transactional.html
      configureRedis = true;

      phpOptions."opcache.interned_strings_buffer" = 32;

      secretFile = config.age.secrets.nextcloud-secret-file.path;

      config = {
        adminpassFile = config.age.secrets.nextcloud-adminpass-file.path;
        adminuser = "glepage";

        # Database
        dbtype = "pgsql";
        dbuser = databaseName;
        dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = databaseName;
      };

      settings = {
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];

        # Further forces Nextcloud to use HTTPS
        overwriteprotocol = "https";

        # Allows to send emails
        mail_smtpmode = "smtp";
        mail_smtphost = "mail.glepage.com";
        mail_smtpport = 587; # STARTTLS
        mail_smtpauth = true;
        mail_smtpname = "nextcloud@glepage.com";
        # mail_smtppassword is in the `cfg.secretFile`
        mail_smtpstreamoptions.ssl = {
          allow_self_signed = true;
          verify_peer = false;
          verify_peer_name = false;
        };

        default_phone_region = "FR";

        # https://github.com/NixOS/nixpkgs/issues/192400
        "integrity.check.disabled" = true;

        # Some background jobs only run once a day.
        # When an hour is defined (timezone is UTC) for this config, the background jobs which
        # advertise themselves as not time-sensitive will be delayed during the “working” hours and
        # only run in the 4 hours after the given time.
        # This is e.g. used for activity expiration, suspicious login training, and update checks.

        # A value of 1 will only run these background jobs between 01:00am UTC and 05:00am UTC.
        maintenance_window_start = 1;
      };
    };
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
  };
}
