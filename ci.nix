let

  dimension = name: attrs: f:
    builtins.mapAttrs
      (k: v:
       let o = f k v;
       in o // { recurseForDerivations = o.recurseForDerivations or true; }
      )
      attrs
    // { meta.dimension.name = name; };
  
  haskellPackages = pkgs:
    let
      projectPackages =
        pkgs.haskell-nix.haskellLib.selectProjectPackages 
          (import ./pkg/hs { inherit pkgs; });

      # These functions pull out from the Haskell package all the
      # components of a particular type - which ci will then build
      # as top-level attributes.
      collectChecks = _: xs:
        pkgs.recurseIntoAttrs (builtins.mapAttrs (_: x: x.checks) xs);
      collectComponents = type: xs:
        pkgs.haskell-nix.haskellLib.collectComponents' type xs;
    in
      # This computes the Haskell package set sliced by component type - these
      # are then displayed as the haskell build attributes in hercules ci.
      pkgs.recurseIntoAttrs
        (dimension "Haskell component" {
            "library" = collectComponents;
            "tests" = collectComponents;
            "benchmarks" = collectComponents;
            "exes" = collectComponents;
            "checks" = collectChecks;
          }
          # Apply the selector to the Haskell (stack) project, aka package set.
          (type: selector: (selector type) projectPackages));

  native = import ./nix/nixpkgs.nix { };
  musl64 = import ./nix/nixpkgs.nix {
    crossSystem = native.lib.systems.examples.musl64;
  };

  shared = import ./default.nix { pkgs = native; };
  static = import ./default.nix { pkgs = musl64; };
  haskell = haskellPackages musl64;

  package = native.stdenvNoCC.mkDerivation rec {
    name = "release-package";
    nativeBuildInputs = [ native.coreutils native.gzip native.gnutar ];
    phases = [ "installPhase" ];
    installPhase = ''
    set -x

    mkdir $out

    tar vczf $out/release.tar.gz \
      --owner=0 --group=0 --mode=u+rw,uga+r \
      --absolute-names \
      --hard-dereference \
      --transform "s,${haskell.exes.urbit-king.urbit-king}/bin/,," \
      --transform "s,''${static.urbit}/bin/,," \
      ${haskell.exes.urbit-king.urbit-king}/bin/urbit-king \
      ${static.urbit}/bin/urbit \
      ${static.urbit}/bin/urbit-worker

    # Write the md5sum output to a file as using `builtins.hashFile`
    # would cause unreliable interaction with `push-gcp-object`.
    md5sum $out/release.tar.gz | awk '{printf $1}' > $out/md5
  '';

    preferLocalBuild = true;
  };

  md5 = builtins.readFile "${package}/md5";

in static // {
  inherit (shared) herb;
  inherit haskell;
  
  release = native.push-gcp-object {
    inherit md5;

    src = "${package}/release.tar.gz";
    bucket = "tlon-us-terraform";
    object = "releases/${md5}.tar.gz";
    serviceAccountKey = builtins.readFile("/var/run/keys/service-account.json");
  };
}
