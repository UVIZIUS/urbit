{ callPackage }:

{
  bootFakeShip = callPackage ./boot-fake-ship { };

  fetchGithubLFS = callPackage ./fetch-github-lfs { };

  pushStorageObject = callPackage ./push-storage-object { };
}
