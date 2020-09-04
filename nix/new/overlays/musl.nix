final: prev:

let

  lib = prev.lib;

  isStatic = prev.stdenv.hostPlatform.isStatic;
  isMusl = prev.stdenv.hostPlatform.isMusl;

  optionalsNull = xs:
    lib.optionals (xs != null) xs;

  overrideWhen = cond: pkg: args:
    if cond then pkg.override args else pkg;

  overrideAttrsWhen = cond: pkg: f:
    if cond then pkg.overrideAttrs f else pkg;

in {
  libsigsegv = overrideAttrsWhen isStatic prev.libsigsegv (old: {
    patches =
      optionalsNull old.patches ++ [
        ../pkgs/libsigsegv/sigcontext-redefined-fix.patch
      ];
  });

  secp256k1 = overrideAttrsWhen isStatic prev.secp256k1 (old: {
    nativeBuildInputs =
      optionalsNull old.nativeBuildInputs ++ [
        prev.buildPackages.stdenv.cc
      ];
  });

  rhash = overrideWhen isMusl prev.rhash { stdenv = prev.gcc9Stdenv; };
  numactl = overrideWhen isMusl prev.numactl { stdenv = prev.gcc9Stdenv; };
  lmdb = overrideWhen isMusl prev.lmdb { stdenv = prev.gcc9Stdenv; };
}
