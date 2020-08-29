{ pkgs }:

pkgs.libsigsegv.overrideAttrs (_oldAttrs: {
  patches = [
    ./fault-linux-i386.patch
    ./fault-linux-x86_64-old.patch
  ];
})
