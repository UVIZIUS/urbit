{ lib
, stdenv
, argon2u
, ca-bundle
, curl
, ed25519
, ent
, ge-additions
, gmp
, h2o
, ivory-header
, libaes-siv
, libscrypt
, libsigsegv
, libuv
, lmdb
, murmur3
, openssl
, secp256k1
, softfloat3
, zlib
, debug ? false
}:

let

in stdenv.mkDerivation rec {
  pname = "urbit";
  version = builtins.readFile "${src}/version";
  exename = if debug then "urbit-debug" else "urbit";
  src = lib.cleanSource ../../../pkg/urbit;

  buildInputs = [
    argon2u
    ca-bundle
    curl
    ed25519
    ent
    ge-additions
    gmp
    h2o
    ivory-header
    libaes-siv
    libscrypt
    libsigsegv
    libuv
    lmdb
    murmur3
    openssl
    secp256k1
    softfloat3
    zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./build/urbit $out/bin/$exename
    cp ./build/urbit-worker $out/bin/$exename-worker
  '';

  # See https://github.com/NixOS/nixpkgs/issues/18995
  hardeningDisable = lib.optionals debug [ "all" ];

  CFLAGS = if debug then "-O0 -g" else "-O3 -g -Werror";
  MEMORY_DEBUG = debug;
  CPU_DEBUG = debug;
  EVENT_TIME_DEBUG = false;
}
