{ pkgs }:

pkgs.stdenv.mkDerivation {
  name    = "libaes_siv";
  src     = ../../../pkg/libaes_siv;

  buildInputs = [ pkgs.openssl ];

  unpackPhase  = "true";
  installPhase = ''
    cp -r $src ./src
    chmod -R u+w ./src
    cd ./src

    PREFIX="$out" make install
  '';
}
