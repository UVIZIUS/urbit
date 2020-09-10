{ stdenvNoCC
, fetchGithubLFS
, bootFakeShip
, solid
, urbit
, arvo
, herb
}@args:

import ../generic.nix (args // {
  name = "brass";
})
