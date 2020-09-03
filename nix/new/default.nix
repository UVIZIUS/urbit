{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
, overlays ? []
, crossOverlays ? []
, sources ? {}
}:

let

  extraSources = import ../sources.nix { inherit pkgs; } // sources;

  haskellNix = import extraSources."haskell.nix" {
    sourcesOverride = {
      hackage = extraSources."hackage.nix";
      stackage = extraSources."stackage.nix";
    };
  };

  extraLib = import ./lib { inherit pkgs; };

  extraOverlays =
    haskellNix.overlays ++ [
      (_final: _prev: {
        # Add top-level sources attribute so we can use `pkgs.sources`
        # in subsequent overlays.
        sources = extraSources;

        # Add our custom library and utility functions.
      } // extraLib)

      # General nixpkgs and local package overrides.
      (import ./overlays/pkgs.nix)
    ];

    extraCrossOverlays = [
      # Add general musl+static overrides which are guarded by the host platform
      # so we can apply them unconditionally.
      (import ./overlays/musl.nix)
    ];

  pkgs = import extraSources.nixpkgs {
    inherit system crossSystem;

    config = haskellNix.config // config;
    overlays = extraOverlays ++ overlays;
    crossOverlays = extraCrossOverlays ++ crossOverlays;
  };

in pkgs
