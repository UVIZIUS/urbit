{ lib, stdenv, ed25519 }:

stdenv.mkDerivation {
  name = "ge-additions";
  src = lib.cleanSource ../../../../pkg/ge-additions;

  buildInputs = [ ed25519 ];

  installFlags = [ "PREFIX=$(out)" ];

  enableParallelBuilding = true;
}

