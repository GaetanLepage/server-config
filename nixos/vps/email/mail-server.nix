{inputs, ...}: let
  base_domain = "glepage.com";
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.${base_domain}";

    domains = [
      base_domain
      "grenug.fr"
    ];

    # Let the server create new (self signed) certificates on the fly.
    certificateScheme = "selfsigned";

    # Clashes with Adguard
    localDnsResolver = false;

    # To generate the hash:
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "gaetan@${base_domain}" = {
        hashedPassword = "$2b$05$ypXOSOtY8tOzh1c6/G.lkesf9NaiHHFiUi0ZbC/gk1wWlcGtyRCrS";
        aliases = [
          "postmaster@${base_domain}"
          "mail@grenug.fr"
          "3iTYog@${base_domain}"
          "gaetan-medium@${base_domain}"
        ];
      };

      ################################
      # Aliases for deleted accounts #
      ################################
      "gaetan-inp-org@${base_domain}" = {
        hashedPassword = "$2b$05$WYcyz0ouNQersRO2M8vfNO3xK3g3p0HPYPJrGwWOMx/CImiDtIvnu";
      };
      "gaetan-inp-fr@${base_domain}" = {
        hashedPassword = "$2b$05$kkIjgZQNey4GT9wtkcL53OjuwXS7gG/fJ586w3vzCEvhPt38WVbOq";
      };
      "gaetan-lepage-knives@${base_domain}" = {
        hashedPassword = "$2b$05$P.hQu3fexLTdofF7KP97wuLf.aG81ChHsiXj43l9rYuQABaC5GrD.";
      };

      ###########
      # Famileo #
      ###########
      "thierry.famileo@${base_domain}" = {
        hashedPassword = "$2b$05$p.DRno51jAtjNIxkh47t8Oh9DdhCR2pWBhhjVyDy0X1Z5h78VYmwm";
      };
      "francoise.famileo@${base_domain}" = {
        hashedPassword = "$2b$05$Gww22I/3wTjPzY/f9QzdDeFL/0SgCX8po34QEweP3FRf2dFrRPbVO";
      };
    };

    backup.enable = true;
  };
}
