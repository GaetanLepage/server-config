{
  description = "Server configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

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
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
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

  outputs = {
    self,
    flake-parts,
    nixpkgs,
    agenix-rekey,
    devshell,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
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
        nixosConfigurations = let
          system = "x86_64-linux";

          mkHost = hostname:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs.inputs = inputs;
              modules = [./nixos/${hostname}];
            };
        in {
          server = mkHost "server";
          feroe = mkHost "feroe";
          vps = mkHost "vps";
        };
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
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
                  --build-host root@"$hostname"
              '';
            }
            {
              name = "update";
              command = ''
                echo "=> Updating flake inputs"
                nix flake update

                deploy vps
                deploy feroe
                deploy server
              '';
            }
          ];
        };
      };
    };
}
