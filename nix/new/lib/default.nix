{ pkgs }:

{
  fetch-github-lfs = import ./fetch-github-lfs.nix { inherit pkgs; };
  push-gcp-object = import ./push-gcp-object { inherit pkgs; };
}
