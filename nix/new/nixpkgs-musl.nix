{ system ? builtins.currentSystem
, config ? {}
, overlays ? {}
, sources ? {}
pkgs ? import ./nix/default.nix { inherit system crossSystem config sourcesOverride; }
}:

import ./nixpkgs {
  crosssystem

  crossSystem = lib.systems.examples.musl64;
}
