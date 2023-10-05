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
        buildInputs = [pkgs.devkitNix.devkitARM];
        shellHook = ''
          ${pkgs.devkitNix.devkitARM.shellHook}
        '';
      };
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "devkitARM-example";
        src = ./.;

        makeFlags = ["TARGET=example"];
        preBuild = pkgs.devkitNix.devkitARM.shellHook;
        installPhase = ''
          cp example.nds $out
        '';
      };
    };
}
