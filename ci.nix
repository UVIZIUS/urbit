let
 
  pkgs = import ./nix/new { };

  # These functions pull out from the Haskell package all the
  # components of a particular type - which ci will then build
  # as top-level attributes.

  dimension = name: attrs: f:
    builtins.mapAttrs
      (k: v:
       let o = f k v;
       in o // { recurseForDerivations = o.recurseForDerivations or true; }
      )
      attrs
    // { meta.dimension.name = name; };

  collectChecks = _: xs:
    pkgs.recurseIntoAttrs (builtins.mapAttrs (_: x: x.checks) xs);

  collectComponents = type: xs:
    pkgs.haskell-nix.haskellLib.collectComponents' type xs;

  haskellComponents = ps:
    pkgs.recurseIntoAttrs
      (dimension "haskell" {
        library = collectComponents;
        tests = collectComponents;
        benchmarks = collectComponents;
        exes = collectComponents;
        checks = collectChecks;
      } (type: selector: (selector type) ps));

  # releaseArchive = pkgs.stdenvNoCC.mkDerivation rec {
  #   name = "release-archive";

  #   nativeBuildInputs = [
  #     pkgs.coreutils
  #     pkgs.gzip
  #     pkgs.gnutar
  #   ];

  #   phases = [ "installPhase" ];

  #   installPhase = ''
  #   mkdir $out

  #   tar vczf $out/release.tar.gz \
  #     --owner=0 --group=0 --mode=u+rw,uga+r \
  #     --absolute-names \
  #     --hard-dereference \
  #     --transform "s,${haskell.exes.urbit-king.urbit-king}/bin/,," \
  #     --transform "s,${static.urbit}/bin/,," \
  #     ${haskell.exes.urbit-king.urbit-king}/bin/urbit-king \
  #     ${static.urbit}/bin/urbit \
  #     ${static.urbit}/bin/urbit-worker

  #   # Write the md5sum output to a file as using `builtins.hashFile`
  #   # would cause unreliable interaction with `push-gcp-object`.
  #   md5sum $out/release.tar.gz | awk '{printf $1}' > $out/md5
  # '';

  #   preferLocalBuild = true;
  # };

in {
  native = {
    inherit (pkgs) herb urbit urbit-debug;
  };

  static = {
    inherit (pkgs.pkgsStatic) urbit urbit-debug;
   };

  haskell =
    haskellComponents
      (pkgs.haskell-nix.haskellLib.selectProjectPackages pkgs.pkgsStatic.urbit-hs);

  # release =
  #   let
  #     md5 = builtins.readFile "${releaseArchive}/md5";
  #   in pkgs.push-gcp-object {
  #     inherit md5;

  #     src = "${releaseArchive}/release.tar.gz";
  #     bucket = "tlon-us-terraform";
  #     object = "releases/${md5}.tar.gz";
  #     serviceAccountKey = builtins.readFile("/var/run/keys/service-account.json");
  #   };
}
