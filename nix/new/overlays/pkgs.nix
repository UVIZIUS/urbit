final: prev:

{
  argon2u = final.callPackage ../pkgs/argon2u { };

  ca-bundle = final.callPackage ../pkgs/ca-bundle { };

  ed25519 = final.callPackage ../pkgs/ed25519 { };

  ent = final.callPackage ../pkgs/ent { };

  ge-additions = final.callPackage ../pkgs/ge-additions { };

  h2o = final.callPackage ../pkgs/h2o { };

  ivory-header = final.callPackage ../pkgs/ivory-header { };

  libaes-siv = final.callPackage ../pkgs/libaes-siv { };

  libscrypt = final.callPackage ../pkgs/libscrypt { };

  murmur3 = final.callPackage ../pkgs/murmur3 { };

  softfloat3 = final.callPackage ../pkgs/softfloat3 { };

  urbit = final.callPackage ../pkgs/urbit { };

  urbit-debug = final.callPackage ../pkgs/urbit { debug = true; };

  herb = final.callPackage ../pkgs/herb { };

  haskellProject = final.callPackage ../../../pkg/hs { };
} 
