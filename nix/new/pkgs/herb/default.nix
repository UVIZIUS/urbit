{ lib, stdenvNoCC, python }:

stdenvNoCC.mkDerivation {
  name  = "herb";
  src = ../../../../pkg/herb/herb;

  buildInputs = [ (python.withPackages (py: [ py.requests ])) ];

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin 
    cp $src $out/bin/herb
    chmod +x $out/bin/herb
  '';
}
