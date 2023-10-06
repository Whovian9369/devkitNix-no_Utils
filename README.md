Hello! I forked the [original repo](https://github.com/bandithedoge/devkitNix) to try building some Switch homebrew on NixOS but without requiring `flake-utils` in each flake to do so!

Honestly, it's untested as all I ended up doing was remove `flake-utils` being required from each flake.

Pushing the as it currently is, so please add an issue if you encounter issues, or pull request if you know how to solve them!
The original readme is just below.

-------------

![devkitNix](pic.jpg)

This flake allows you to use [devkitPro](https://devkitpro.org/) toolchains in your Nix expressions.

# Usage

devkitNix works by extracting dkp's official Docker images, patching the binaries and including everything in a single environment. Each package provides a complete toolchain including all available portlibs.

To use the toolchains, create a `flake.nix` file and import devkitNix as shown in the example below:

```nix
# This is an example flake.nix for a Switch project based on devkitA64.
# It will work on any devkitPro example with a Makefile out of the box.
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
        # devkitNix provides an overlay with the toolchains
        overlays = [devkitNix.overlays.default];
      };
    in {

      devShells.${system}.default = pkgs.mkShell {
        # devkitNix packages also provide relevant tools you may want available
        # in your PATH.
        buildInputs = [pkgs.devkitNix.devkitA64];

        # Each package provides a shell hook that sets all necessary
        # environmental variables. This part is necessary, otherwise your build
        # system won't know where to find devkitPro. By setting these
        # variables we allow devkitPro's example Makefiles to work out of the box.
        inherit (pkgs.devkitNix.devkitA64) shellHook;
      };

      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "devkitA64-example";
        src = ./.;

        # `TARGET` determines the name of the executable.
        makeFlags = ["TARGET=example"];
        # The shell hook is used in the build to point your build system to
        # devkitPro.
        preBuild = pkgs.devkitNix.devkitA64.shellHook;
        # This is a simple Switch app example that only builds a single
        # executable. If your project outputs multiple files, make `$out` a
        # directory and copy everything there.
        installPhase = ''
          cp example.nro $out
        '';
      };

    };
}
```

See the [examples](examples/) directory for complete working homebrew apps.
