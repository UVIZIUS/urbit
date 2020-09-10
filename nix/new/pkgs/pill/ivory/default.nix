{ stdenvNoCC
, fetchGithubLFS
, bootFakeShip
, solid
, urbit
, arvo
, herb
, xxd
}:

let

  name = "ivory";

  pill = import ../generic.nix {
    inherit stdenvNoCC fetchGithubLFS bootFakeShip solid urbit arvo herb name;
  };

in pill // {
  header = import ../header.nix {
    inherit stdenvNoCC xxd name;

    src = pill.stale;
  };
}
