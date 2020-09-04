{ lib, stdenv, openssl }:

stdenv.mkDerivation {
  name = "libaes-siv";
  src = lib.cleanSource ../../../../pkg/libaes_siv;

  buildInputs = [ openssl ];

  installFlags = [ "PREFIX=$(out)" ];

  enableParallelBuilding = true;
}
