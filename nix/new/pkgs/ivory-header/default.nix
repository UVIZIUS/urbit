{ stdenvNoCC, fetchGithubLFS, xxd }:

stdenvNoCC.mkDerivation {
  name = "ivory-header";
  src = fetchGithubLFS { src = ../../../../bin/ivory.pill; };

  nativeBuildInputs = [ xxd ];

  phases = [ "installPhase" ];

  installPhase = ''
    cat $src > u3_Ivory.pill
    xxd -i u3_Ivory.pill > ivory.h

    mkdir -p $out/include
    mv ivory.h $out/include/
  '';

  preferLocalBuild = true;
}
