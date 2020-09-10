{ lib
, stdenv
, pkgconfig
, argon2u
, ca-bundle
, curl
, ed25519
, ent
, ge-additions
, gmp
, h2o
, ivory
, libaes-siv
, libscrypt
, libsigsegv
, libssh2
, libuv
, lmdb
, murmur3
, nghttp2
, openssl
, secp256k1
, softfloat3
, zlib
, static ? stdenv.hostPlatform.isStatic
, debug ? false
}:

stdenv.mkDerivation rec {
  pname = "urbit";
  version = builtins.readFile "${src}/version";
  src = lib.cleanSource ../../../../pkg/urbit;

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [
    argon2u
    ca-bundle
    curl
    ed25519
    ent
    ge-additions
    gmp
    h2o
    ivory.header
    libaes-siv
    libscrypt
    libsigsegv
    libssh2
    libuv
    lmdb
    murmur3
    nghttp2
    openssl
    secp256k1
    softfloat3
    zlib
  ];

  postPatch = ''
    patchShebangs ./configure
  '';
  
  installPhase = ''
    mkdir -p $out/bin
    cp ./build/urbit $out/bin/urbit
    cp ./build/urbit-worker $out/bin/urbit-worker
  '';

  CFLAGS =
    [ (if debug then "-O0" else "-O3")
      "-g"
    ] ++ lib.optionals (!debug) [ "-Werror" ]
      ++ lib.optionals static [ "-static" ];

  MEMORY_DEBUG = debug;
  CPU_DEBUG = debug;
  EVENT_TIME_DEBUG = false;

  # See https://github.com/NixOS/nixpkgs/issues/18995
  hardeningDisable = lib.optionals debug [ "all" ];

  enableParallelBuilding = true;

  meta = {
    inherit debug;
  };
}
