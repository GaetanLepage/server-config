{ config, ... }:
let
  domain = "board.glepage.com";
in
{
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

  systemd =
    let
      serviceName = "vikunja-backup";
    in
    {
      services.${serviceName} = {
        description = "Script that periodically backups the vikunja sqlite database to /var/backup";

        serviceConfig = {
          Type = "oneshot";
        };
        script = ''
          cp -f ${config.services.vikunja.database.path} /var/backup/
        '';
      };

      timers.${serviceName} = {
        wantedBy = [ "timers.target" ];
        after = [ "multi-user.target" ];

        timerConfig = {
          OnCalendar = "hourly";
          Persistent = "yes";
        };
      };
    };
}
