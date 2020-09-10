let

  native = import ./nix/new { };
  musl64 = import ./nix/new { crossSystem = native.lib.systems.examples.musl64; };
 
  haskellProject = project:
    let
      # These functions pull out from the Haskell package all the
      # components of a particular type - which ci will then build
      # as top-level attributes.

      dimension = name: attrs: f:
        builtins.mapAttrs (k: v:
          let o = f k v;
          in o // { recurseForDerivations = o.recurseForDerivations or true; }
        ) attrs // { meta.dimension.name = name; };

      packages =
        native.haskell-nix.haskellLib.selectProjectPackages project;

      collectChecks = _: xs:
        native.recurseIntoAttrs (builtins.mapAttrs (_: x: x.checks) xs);

      collectComponents = type: xs:
        native.haskell-nix.haskellLib.collectComponents' type xs;

    in
      # This computes the Haskell package set sliced by component type - these
      # are then displayed as the haskell build attributes in hercules ci.
      native.recurseIntoAttrs
        (dimension "haskell" {
          library = collectComponents;
          tests = collectComponents;
          benchmarks = collectComponents;
          exes = collectComponents;
          checks = collectChecks;
        } (type: selector: (selector type) packages));

  haskell = haskellProject musl64.urbit-hs;

  releaseArchive = native.stdenvNoCC.mkDerivation {
    name = "release-archive";

    nativeBuildInputs = [ native.coreutils native.gzip native.gnutar ];

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir $out

      tar vczf $out/release.tar.gz \
        --owner=0 --group=0 --mode=u+rw,uga+r \
        --absolute-names \
        --hard-dereference \
        --transform "s,${haskell.exes.urbit-king.urbit-king}/bin/,," \
        --transform "s,${musl64.pkgsStatic.urbit}/bin/,," \
        ${haskell.exes.urbit-king.urbit-king}/bin/urbit-king \
        ${musl64.pkgsStatic.urbit}/bin/urbit \
        ${musl64.pkgsStatic.urbit}/bin/urbit-worker

      md5sum $out/release.tar.gz | awk '{printf $1}' > $out/md5
    '';

    preferLocalBuild = true;
  };

in {
  native = native.recurseIntoAttrs {
    inherit (native) arvo herb urbit urbit-debug ivory brass solid;
  };

  musl64 = native.recurseIntoAttrs {
    inherit (musl64.pkgsStatic) urbit urbit-debug;
  };

  inherit haskell;
  
  release =
    let
      md5 = builtins.readFile "${releaseArchive}/md5";
    in native.pushStorageObject {
      inherit md5;

      src = "${releaseArchive}/release.tar.gz";
      bucket = "tlon-us-terraform";
      object = "releases/${md5}.tar.gz";
      serviceAccountKey = builtins.readFile("/var/run/keys/service-account.json");
    };
}
