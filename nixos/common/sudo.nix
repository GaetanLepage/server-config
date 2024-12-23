{
  # Security
  environment.shellAliases.sudo = "doas";
  security = {
    sudo.enable = false;
    doas = {
      enable = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          persist = true;
        }
      ];
    };
  };
}
