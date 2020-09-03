final: prev:

let

  isStatic = prev.stdenv.hostPlatform.isStatic;
  isMusl = prev.stdenv.hostPlatform.isMusl;

  unlessNull = xs: prev.lib.optionals (xs != null) xs;

in if !(isStatic && isMusl) then {} else {
  libsigsegv = prev.libsigsegv.overrideAttrs (old: {
    patches = unlessNull old.patches ++ [
      ../pkgs/libsigsegv/sigcontext-redefined-fix.patch
    ];
  });

  secp256k1 = prev.secp256k1.overrideAttrs (old: {
    nativeBuildInputs =
      unlessNull old.nativeBuildInputs ++ [
        prev.buildPackages.stdenv.cc
      ];
  });

  rhash = prev.rhash.override { stdenv = prev.gcc9Stdenv; };

  lmdb = prev.lmdb.override { stdenv = prev.gcc9Stdenv; };
}
