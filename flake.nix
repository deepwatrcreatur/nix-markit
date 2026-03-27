{
  description = "Nix package for markit - universal document-to-markdown converter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = self.packages.${system}.markit;
          markit = pkgs.callPackage ./package.nix { };
        }
      );

      overlays.default = final: prev: {
        markit = self.packages.${prev.system}.markit;
      };
    };
}
