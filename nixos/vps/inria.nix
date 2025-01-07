{
  services.caddy =
    let
      domain = "robotlearn.ovh";
    in
    {
      virtualHosts = {
        "tensorboard.glepage.com".extraConfig = ''
          import vpn
          handle @vpn {

              handle_path /rlan/* {
                  reverse_proxy 10.10.10.4:9090
              }
              handle_path /exputils/* {
                  reverse_proxy 10.10.10.4:9091
              }
          }
        '';
        "wiki.${domain}".extraConfig = ''
          redir https://robotlearn.gitlabpages.inria.fr/wiki/
        '';
      };

      reverseProxies = {
        ${domain} = {
          localIp = "10.10.10.7";
          port = 8000;
        };

        "grafana.${domain}" = {
          localIp = "10.10.10.6";
          port = 3000;
        };

        "ollama.${domain}" = {
          localIp = "10.10.10.4"; # auriga
          port = 11434;
        };
      };
    };
}
