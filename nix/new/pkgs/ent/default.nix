{ lib, stdenv }:

stdenv.mkDerivation {
  name = "ent";
  src = lib.cleanSource ../../../../pkg/ent;

  postPatch = ''
    patchShebangs ./configure
  '';

  installFlags = [ "PREFIX=$(out)" ];
}
