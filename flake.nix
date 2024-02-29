{
  description = "Server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    simple-nixos-mailserver,
    agenix,
    agenix-rekey,
    devshell,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.devshell.flakeModule
      ];

      flake = {
        agenix-rekey = agenix-rekey.configure {
          userFlake = self;
          nodes = self.nixosConfigurations;
        };

        # System configuration
        nixosConfigurations = let
          system = "x86_64-linux";

          mkHost = hostname: extraModules:
            nixpkgs.lib.nixosSystem {
              inherit system;
              modules =
                [
                  ./nixos/${hostname}
                  agenix.nixosModules.default
                  agenix-rekey.nixosModules.default
                  {age.rekey.localStorageDir = ./secrets/${hostname};}
                ]
                ++ extraModules;
            };
        in {
          server = mkHost "server" [
            simple-nixos-mailserver.nixosModule
          ];
          feroe = mkHost "feroe" [];
        };
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        formatter = pkgs.alejandra;

        devshells.default = {
          packages = [
            agenix-rekey.packages.${system}.default
          ];

          commands = [
            {
              name = "deploy";
              command = ''
                 hostname=$1

                echo -e "\n=> Updating '$hostname' system"
                 nixos-rebuild switch \
                   --verbose \
                   --fast \
                   --flake .#"$hostname" \
                   --target-host root@"$hostname" \
                   --build-host root@"$hostname"
              '';
            }
            {
              name = "update";
              command = ''
                echo "=> Updating flake inputs"
                nix flake update

                deploy feroe
                deploy server
              '';
            }
          ];
        };
      };
    };
}
