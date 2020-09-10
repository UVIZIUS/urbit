{ stdenvNoCC, xxd, name, src }:

stdenvNoCC.mkDerivation {
  inherit src;
  name = "${name}-header";
  nativeBuildInputs = [ xxd ];
  phases = [ "installPhase" ];

  installPhase = ''
    file="${name}"
    file="u3_''${file^}.pill"

    header "writing $file"

    mkdir -p $out/include

    cat $src > $file

    xxd -i $file > $out/include/${name}.h
  '';

  preferLocalBuild = true;
}
