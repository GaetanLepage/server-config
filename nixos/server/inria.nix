{
  services.caddy = {
    virtualHosts = let
      domain_name = "glepage.com";
    in {
      "tensorboard.${domain_name}".extraConfig = ''
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

      "jupyter.${domain_name}".extraConfig = ''
        import vpn
        reverse_proxy @vpn 10.10.10.4:8080
      '';

      "robotlearn.${domain_name}".extraConfig = ''
        reverse_proxy 10.10.10.7:8000
      '';
    };
  };
}
