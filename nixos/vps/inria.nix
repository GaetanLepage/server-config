{
  services.caddy = {
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
      "wiki.robotlearn.ovh".extraConfig = ''
        redir https://robotlearn.gitlabpages.inria.fr/wiki/
      '';
    };

    reverseProxies = {
      "robotlearn.ovh" = {
        localIp = "10.10.10.7";
        port = 8000;
      };

      "grafana.robotlearn.ovh" = {
        localIp = "10.10.10.6";
        port = 3000;
      };
    };
  };
}
