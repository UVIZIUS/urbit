{ sources ? import ./sources.nix, ... }@args:

let

  haskellNix = import sources.haskell-nix { };

  nixpkgsArgs = haskellNix.nixpkgsArgs // args;

  # By using haskell.nix's own pin we should get a higher cache
  # hit rate from `cachix use iohk`.
  pkgs = import haskellNix.sources.nixpkgs-2003 nixpkgsArgs;

in pkgs // {
  inherit sources;

  fetch-github-lfs = import ./lib/fetch-github-lfs.nix { inherit pkgs; };
  push-gcp-object = import ./lib/push-gcp-object.nix { inherit pkgs; };
}
