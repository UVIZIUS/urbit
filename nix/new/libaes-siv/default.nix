{ stdenv, openssl }:

stdenv.mkDerivation {
  name = "libaes-siv";
  src = ../../../pkg/libaes_siv;

  buildInputs = [ openssl ];

  installFlags = [ "PREFIX=$(out)" ];
}

