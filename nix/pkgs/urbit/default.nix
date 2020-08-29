{ pkgs
, debug
, argon2
, ed25519
, ent
, ge-additions
, libsigsegv
, libaes_siv
, h2o
, murmur3
, scrypt
, secp256k1
, softfloat3
, uv
, ivory-header
, ca-header
}:

let

  name =
    if debug then "urbit-debug" else "urbit";

  meta = {
    inherit debug;
    bin   = "${urbit}/bin/${name}";
    flags = if debug then [ "-g" ] else [];
    exe   = ''${meta.bin} ${pkgs.lib.strings.concatStringsSep " " meta.flags}'';
  };

  deps = with pkgs; [
    curl
    gmp
    libsigsegv
    openssl
    zlib
    lmdb
  ];

  vendor = [
    argon2
    softfloat3
    ed25519
    ent
    ge-additions
    libaes_siv
    h2o
    scrypt
    uv
    murmur3
    secp256k1
    ivory-header
    ca-header
  ];

  urbit = pkgs.stdenv.mkDerivation {
    inherit name meta;

    src = ../../../pkg/urbit;

    buildInputs = deps ++ vendor;

    # FIXME: (brendan): Why is -j8 hardcoded - causes problems on CI agents.
    installPhase = ''
      make all -j8
      make test

      mkdir -p $out/bin
      cp ./build/urbit $out/bin/${name}
      cp ./build/urbit-worker $out/bin/${name}-worker
    '';

    # See https://github.com/NixOS/nixpkgs/issues/18995
    hardeningDisable = if debug then [ "all" ] else [];

    CFLAGS           = if debug then "-O0 -g" else "-O3 -g -Werror";
    MEMORY_DEBUG     = debug;
    CPU_DEBUG        = debug;
    EVENT_TIME_DEBUG = false;
  };

in

urbit
