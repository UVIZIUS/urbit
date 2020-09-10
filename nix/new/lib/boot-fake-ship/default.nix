{ stdenvNoCC, cacert }:

{ urbit
, arvo ? null
, herb
, pill 
, ship
}:

stdenvNoCC.mkDerivation {
  name = "fake" + ship;
  buildInputs = [ cacert urbit herb ];
  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    set -euo pipefail

    # This is to ensure that `cacert` is set as some form of buildInput, 
    # otherwise we'll error with:
    #   http: fail (0, 504): unable to get local issuer certificate
    if ! [ -f "$SSL_CERT_FILE" ]; then
      header "$SSL_CERT_FILE doesn't exist"
      exit 1
    fi

    if [ -z "${arvo}" ]; then
      urbit -d -F "${ship}" -B "${pill}" ./pier
    else
      urbit -d -F "${ship}" -A "${arvo}" -B "${pill}" ./pier
    fi

    cleanup () {
      if [ -f ./pier/.vere.lock ]; then
        kill $(< ./pier/.vere.lock) || true
      fi
    }

    trap cleanup EXIT INT QUIT

    check () {
      [ 3 -eq "$(herb ./pier -d 3)" ]
    }

    if check && sleep 10 && check; then
      header "boot success"
      herb ./pier -p hood -d '+hood/exit'
    else
      header "boot failure"
      kill $(< ./pier/.vere.lock) || true
      exit 1
    fi
  '';

  installPhase = ''
    mv ./pier $out
  '';
}
