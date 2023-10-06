{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devkitNix.url = "github:Whovian9369/devkitNix-no_Utils";
  };

  outputs = {
    self,
    nixpkgs,
    devkitNix,
    ...
  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devkitNix.overlays.default];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [pkgs.devkitNix.devkitA64];
        inherit (pkgs.devkitNix.devkitA64) shellHook;
      };
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "devkitA64-example";
        src = ./.;

        makeFlags = ["TARGET=example"];
        preBuild = pkgs.devkitNix.devkitA64.shellHook;
        installPhase = ''
          mkdir $out
          cp example.nro $out
        '';
      };
    };
}
