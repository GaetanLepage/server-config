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

      "robotlearn.ovh".extraConfig = ''
        reverse_proxy 10.10.10.7:8000
      '';

      "grafana.robotlearn.ovh".extraConfig = ''
        reverse_proxy 10.10.10.6:3000
      '';

      "wiki.robotlearn.ovh".extraConfig = ''
        redir https://robotlearn.gitlabpages.inria.fr/wiki/
      '';
    };
  };
}
