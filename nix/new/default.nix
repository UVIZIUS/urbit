{ system ? builtins.currentSystem
, config ? {}
, overlays ? []
, sources ? {}
, pkgs ? import ./nixpkgs.nix { inherit system config sources; }
}:

let

  pkgsMusl = import ./nixpkgs.nix {
    inherit system config sources;

    crossSystem = pkgs.lib.systems.examples.musl64;
  };
  
in

{
  inherit pkgs pkgsMusl;
}
