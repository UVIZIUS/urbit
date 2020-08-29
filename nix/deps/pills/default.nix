{ pkgs }:

{
  brass = pkgs.fetch-github-lfs { src = ../../../bin/brass.pill; };
  ivory = pkgs.fetch-github-lfs { src = ../../../bin/ivory.pill; };
  solid = pkgs.fetch-github-lfs { src = ../../../bin/solid.pill; };
}
