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
        buildInputs = [pkgs.devkitNix.devkitPPC];
        inherit (pkgs.devkitNix.devkitPPC) shellHook;
      };
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "devkitPPC-example";
        src = ./.;

        makeFlags = ["TARGET=example"];
        preBuild = pkgs.devkitNix.devkitPPC.shellHook;
        installPhase = ''
          mkdir $out
          cp example.dol $out
        '';
      };
    };
}
