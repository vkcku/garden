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

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
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
      hjem,
      zen-browser,
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
            hjem.nixosModules.default
            sops-nix.nixosModules.sops

            {
              system.configurationRevision = self.rev or "dirty";
              system.nixos.label = self.shortRev or "dirty";
            }
          ];

          specialArgs = { inherit garden hjem; };
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
        lib = import ./lib { lib = nixpkgs.lib; };
        packages = {
          zen-browser = zen-browser.packages."${system}".twilight-unwrapped;
        };
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
          nushell

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
