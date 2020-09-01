final: prev:

let

  lib = prev.lib;
  isMusl = prev.stdenv.hostPlatform.isMusl;

in prev # .pkgsStatic {
   
# pkgsMusl = import ./nix/default.nix {
#     inherit system config sourcesOverride;
#     crossSystem = lib.systems.examples.musl64;
#   };
