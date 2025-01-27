{
  lib,
  config,
  ...
}:
{
  options = {
    services.caddy = {
      reverseProxies = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              port = lib.mkOption {
                type = with lib.types; nullOr port;
                default = null;
              };

              vpn = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };

              localIp = lib.mkOption {
                type = lib.types.str;
                default = "localhost";
              };
            };
          }
        );
      };
    };
  };

  config =
    let
      cfg = config.services.caddy;
    in
    {
      services.caddy = {
        extraConfig = ''
          (vpn) {
              @vpn remote_ip 10.10.10.0/24
          }
        '';

        virtualHosts = lib.mapAttrs (domain: opts: {
          extraConfig =
            let
              proxyStr = opts.localIp + lib.optionalString (opts.port != null) ":${toString opts.port}";
            in
            if opts.vpn then
              ''
                import vpn
                reverse_proxy @vpn ${proxyStr}
              ''
            else
              "reverse_proxy ${proxyStr}";
        }) cfg.reverseProxies;
      };

      networking.hosts =
        let
          localWireguardIp = lib.pipe config.networking.wireguard.interfaces.wg0.ips [
            # [ "10.10.10.x/32" ]
            lib.head
            # "10.10.10.x/32"
            (lib.splitString "/")
            # [ "10.10.10.x" "32" ]
            lib.head
            # "10.10.10.x"
          ];

          /*
            "foo.glepage.com"
            {
              localIp = "10.10.10.42";
              vpn = true;
            };

            [
              { "10.10.10.42" = [ "foo.glepage.com" ]; }
            ]
          */
          mkDnsMapping =
            domain: opts:
            let
              wireguardIp = if opts.localIp == "localhost" then localWireguardIp else opts.localIp;
            in
            lib.optional opts.vpn { ${wireguardIp} = domain; };

          reverseProxies' = lib.concatLists (lib.mapAttrsToList mkDnsMapping cfg.reverseProxies);
        in
        builtins.trace (lib.head reverseProxies') builtins.zipAttrsWith (n: v: v) reverseProxies';
    };
}
