{ stdenv, sources, pkgconfig, cmake, openssl, libuv, zlib }:

stdenv.mkDerivation {
  pname = "h2o";
  version = sources.h2o.rev;
  src = sources.h2o;

  outputs = [ "out" "dev" "lib" ];

  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ openssl libuv zlib ];

  enableParallelBuilding = true;
}
