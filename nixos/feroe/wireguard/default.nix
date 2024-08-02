{
  age.secrets.wireguard-private-key.rekeyFile = ./private-key.age;

  custom.wireguard = {
    enable = true;
    ip = "10.10.10.23";
  };
}
