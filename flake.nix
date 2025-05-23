{
  description = "Server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05-small";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-parts,
      nixpkgs,
      agenix-rekey,
      devshell,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        inputs.devshell.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      flake = {
        agenix-rekey = agenix-rekey.configure {
          userFlake = self;
          inherit (self) nixosConfigurations;
        };

        # System configuration
        nixosConfigurations =
          let
            system = "x86_64-linux";
            mkHost =
              hostname:
              nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs = {
                  inputs = inputs;
                };
                modules = [ ./nixos/${hostname} ];
              };

            hostnames = [
              "tank"
              "feroe"
              "vps"
            ];
          in
          nixpkgs.lib.genAttrs hostnames mkHost;
      };

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          treefmt.config = {
            projectRootFile = "flake.nix";
            flakeCheck = true;
            programs = {
              nixfmt.enable = true;
            };
          };

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
                    --builders ""
                '';
              }
              {
                name = "update";
                command = ''
                  echo "=> Updating flake inputs"
                  nix flake update

                  deploy vps
                  deploy feroe
                  deploy tank

                  git add flake.lock
                  git commit -m "flake.lock: Update"
                  git push
                '';
              }
            ];
          };
        };
    };
}
