{
  description = "My digital garden.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
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
