{ lib, stdenv }:

stdenv.mkDerivation {
  name = "ent";
  src = lib.cleanSource ../../../pkg/ent;

  installFlags = [ "PREFIX=$(out)" ];
}
