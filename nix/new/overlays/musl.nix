final: prev:

let

  isTarget = prev.stdenv.targetPlatform.isMusl;

  unlessNull = xs: prev.lib.optionals (xs != null) xs;

  # This is a fix for gcc's "crtbeginT.o: relocation R_X86_64_32 against hidden
  # symbol `__TMC_END__' can not be used when making a shared object" error
  # which occurs during musl/static compilation.
  stdenv = prev.overrideCC prev.stdenv prev.buildPackages.gcc;

in {
  libsigsegv = prev.libsigsegv.overrideAttrs (old: {
    patches = unlessNull old.patches ++ prev.lib.optionals isTarget
      [ ../pkgs/libsigsegv/sigcontext-redefined-fix.patch ];
  });

  secp256k1 = prev.secp256k1.overrideAttrs (old: {
    nativeBuildInputs = unlessNull old.nativeBuildInputs
      ++ [ prev.buildPackages.stdenv.cc ];
  });

  rhash = prev.rhash.override { inherit stdenv; };

  lmdb = prev.lmdb.override { inherit stdenv; };
}
