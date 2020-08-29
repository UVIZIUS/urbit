{ pkgs, uv }:

pkgs.stdenv.mkDerivation {
  name    = "h2o";
  src     = pkgs.sources.h2o;
  builder = ./builder.sh;

  nativeBuildInputs = [ uv pkgs.binutils pkgs.openssl pkgs.zlib ];
}
