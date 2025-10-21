{
  description = "My digital garden.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # keep-sorted start block=yes newline_separated=yes
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    garden-secrets = {
      url = "git+ssh://git@github.com/vkcku/garden-secrets.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs =
    {
      self,
      disko,
      garden-secrets,
      nixpkgs,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/${hostname}

            disko.nixosModules.disko
            sops-nix.nixosModules.sops

            {
              system.configurationRevision = self.rev or "dirty";
              system.nixos.label = self.shortRev or "dirty";
            }
          ];

          specialArgs = { inherit garden; };
        };

      /**
        Global settings object.
      */
      garden = {
        # This entire configuration is designed assuming it is essentially a single
        # user system. While other users would be created, they will all be service users.
        #
        # If at some point multiple actual users need to be added, this entire system will
        # have to be changed, but it keeps things simple for now.
        username = "vkcku";
        secrets = garden-secrets;
      };
    in
    {
      nixosConfigurations = {
        ares = mkSystem "ares";
        joli = mkSystem "joli";
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Development helpers.
          nil

          # Formatters/linters.
          # keep-sorted start
          keep-sorted
          nixfmt-rfc-style
          python313Packages.mdformat
          shellcheck
          shfmt
          taplo
          treefmt
          typos
          # keep-sorted end
        ];
      };
    };
}
