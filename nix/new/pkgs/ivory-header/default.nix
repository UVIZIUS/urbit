{ stdenv, fetch-github-lfs, xxd }:

stdenv.mkDerivation {
  name = "ivory-header";
  src = fetch-github-lfs { src = ../../../../bin/ivory.pill; };

  nativeBuildInputs = [ xxd ];

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    cat $src > u3_Ivory.pill
    xxd -i u3_Ivory.pill > ivory.h
    mkdir -p $out/include
    mv ivory.h $out/include/
  '';

  preferLocalBuild = true;
}

