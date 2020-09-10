{ stdenvNoCC
, fetchGithubLFS
, bootFakeShip
, urbit
, arvo
, herb
}:

let

  stale = fetchGithubLFS { src = ../../../../../bin/solid.pill; };

  pier = bootFakeShip {
    inherit urbit arvo herb;

    ship = "zod";
    pill = stale;
  };

  fresh = stdenvNoCC.mkDerivation {
    name = "solid-pill";
    src = pier;
    builder = ./builder.sh;
    buildInputs = [ urbit herb ];

    ARVO = arvo;
  };

in {
  inherit stale fresh;
}
