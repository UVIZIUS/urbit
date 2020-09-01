{ system ? builtins.currentSystem
, crossSystem ? null
, config ? {}
, overlays ? []
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

  extraOverlays =
    haskellNix.overlays ++ [
      (_final: _prev: {
        # Add top-level sources attribute so we can use `pkgs.sources`
        # in subsequent overlays.
        sources = extraSources;

        # Add our custom library functions.
        fetch-github-lfs = import ./lib/fetch-github-lfs.nix { inherit pkgs; };
        push-gcp-object = import ./lib/push-gcp-object.nix { inherit pkgs; };
      })

      # General nixpkgs and local package overrides.
      (import ./overlays/pkgs.nix)

      # Add musl static overrides which are guarded by the host-platform
      # so we can apply them unconditionally.
      (import ./overlays/musl.nix)
    ];

  pkgs = import extraSources.nixpkgs {
    inherit system crossSystem;

    overlays = extraOverlays ++ overlays;
    config = haskellNix.config // config;
  };

in pkgs
