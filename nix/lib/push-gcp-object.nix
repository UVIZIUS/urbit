{ pkgs }:

{ src
, md5
, bucket
, object
, serviceAccountKey
, preferLocalBuild ? true
}:

assert pkgs.lib.asserts.assertMsg (builtins.isString serviceAccountKey)
  "`serviceAccountKey` must be the JSON string contents of a service-account key";

let

  key = builtins.replaceStrings ["\n"] [""] object;
  uri = "gs://${bucket}/${pkgs.lib.removePrefix "/" key}";

  sha256 = builtins.hashString "sha256" "${md5} ${uri}";

in pkgs.stdenvNoCC.mkDerivation {
  name = "gcp-object-md5sum";
  nativeBuildInputs = [ pkgs.coreutils pkgs.xxd pkgs.google-cloud-sdk ];
  phases = [ "installPhase" ];
  installPhase = ''
    set -euo pipefail

    export HOME="."

    gcloud auth activate-service-account --key-file=- <<< '${serviceAccountKey}'

    local_md5=$(echo -n '${md5}' | xxd -r -p | base64)
    remote_md5=
        
    stat_uri() {
      header "retrieving md5 for ${uri}"

      remote_md5=$(gsutil stat '${uri}' \
        | sed -n -e '/Hash (md5):/{s/.*: *//p}' \
        | base64 -d \
        | xxd -p)
    }

    if ! stat_uri; then
       header "copying ${src} to ${uri}"

       gsutil -h "Content-MD5:$local_md5" cp '${src}' '${uri}'

       if ! stat_uri; then
         echo "failed calculating remote uri md5" >&2
         exit 1 
       fi
    fi 

    echo -n "$remote_md5 ${uri}" > $out
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "flat";
  outputHash = sha256;

  inherit preferLocalBuild;
}
