{ pkgs }:

{
  fetchGithubLFS = import ./fetch-github-lfs.nix { inherit pkgs; };
  pushStorageObject = import ./push-storage-object.nix { inherit pkgs; };
}
