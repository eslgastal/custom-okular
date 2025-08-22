{
  description = "A patched Okular flake with patched Poppler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/7df7ff7d8e00218376575f0acdcc5d66741351ee";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
      dejavu_small = with pkgs; stdenv.mkDerivation {
        pname = "dejavu-small-font";
        version = "1.0";
        src = null;
        unpackPhase = "true";
        nativeBuildInputs = [ python312Packages.fonttools
                              dejavu_fonts.minimal ];
        buildPhase = ''
            set -euo pipefail
            FONT="${dejavu_fonts.minimal}/share/fonts/truetype/DejaVuSans.ttf"
            cp "$FONT" DejaVuSans.ttf
            bash "${./make_dejavu_subset.sh}"
        '';
        installPhase = ''
            mkdir -p $out
            mv DejaVuSans-Small-PTBR.ttf $out/
        '';
      };
    in
    {
      overlays.default = (final: prev: {
        kdePackages = prev.kdePackages.overrideScope (kdeFinal: kdePrev: {
          poppler = kdePrev.poppler.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or []) ++ [ ./poppler.patch ];
            postPatch = ''
                substituteInPlace poppler/Form.cc \
                    --replace "@DEJAVU_SANS_PATH@" "${dejavu_small}/DejaVuSans-Small-PTBR.ttf"
                echo "Replaced @DEJAVU_SANS_PATH@ with ${dejavu_small}/DejaVuSans-Small-PTBR.ttf"
            '';
          });
          okular = kdePrev.okular.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or []) ++ [ ./okular.patch ];
          });
        });
      });

      packages.${system} = {
        default = pkgs.kdePackages.okular;
        inherit dejavu_small;
        inherit (pkgs.kdePackages) okular poppler;
      };
    };
}
