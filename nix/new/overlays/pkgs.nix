final: prev:

let

  # Import the `path` with the required arguments automatically, but override
  # any pkgs from global packages `prev` with our own `localPackages`.
  #
  # For example: if `urbit` depends on `h2o` it'll be supplied from the
  # `localPackages` binding - not from `prev` as it's been overriden via
  # `(prev // localPackages) ...`.
  callPackage = path: args:
    prev.lib.callPackageWith (prev // localPackages) path args;

  localPackages = {
    argon2u = callPackage ../argon2u { };
    ca-bundle = callPackage ../ca-bundle { };
    ed25519 = callPackage ../ed25519 { };
    ent = callPackage ../ent { };
    ge-additions = callPackage ../ge-additions { };
    h2o = callPackage ../h2o { };
    ivory-header = callPackage ../ivory-header { };
    libaes-siv = callPackage ../libaes-siv { };
    libscrypt = callPackage ../libscrypt { };
    murmur3 = callPackage ../murmur3 { };
    softfloat3 = callPackage ../softfloat3 { };
    urbit = callPackage ../urbit { };
    urbit-debug  = callPackage ../urbit { debug = true; };
  };

in localPackages
