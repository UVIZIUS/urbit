{ stdenvNoCC
, fetchGithubLFS
, bootFakeShip
, solid
, urbit
, arvo
, herb
, name
}:

assert stdenvNoCC.lib.asserts.assertOneOf "name" name [ "ivory" "brass" ];

let

  stale = fetchGithubLFS { src = ../../../.. + "/bin/${name}.pill"; };

  pier = bootFakeShip {
    inherit urbit arvo herb;

    ship = "zod";
    pill = solid.stale;
  };

  fresh = stdenvNoCC.mkDerivation {
    name = "${name}-pill";
    src = pier;
    buildInputs = [ urbit herb ];
    phases = [ "buildPhase" "installPhase" ];

    buildPhase = ''
      set -euo pipefail

      cp -r $src ./pier
      chmod -R u+rw ./pier

      urbit -d ./pier

      cleanup () {
        if [ -f ./pier/.vere.lock ]; then
          kill $(< ./pier/.vere.lock) || true
        fi
      }

      trap cleanup EXIT INT QUIT

      header "running herb +${name}"

      herb ./pier -P ${name}.pill -d '+${name}'
      herb ./pier -p hood -d '+hood/exit'
    '';

    installPhase = ''
      mv ${name}.pill $out
    '';
  };

in {
  inherit stale fresh;
}
