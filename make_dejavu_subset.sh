#!/bin/bash
# This script assumes the existence of DejaVuSans.ttf in the current
# directory, and generates DejaVuSans-Small-PTBR.ttf in the same dir.

# 1) Subset the font to only the required glyphs
unicodes=(
    "U+0030-0039" # Digits
    "U+0041-005A" # Uppercase letters
    "U+0061-007A" # Lowercase letters
)
other_glyphs=(
    " .:/-"
    "ÀÁÂÃÇÉÊÍÓÔÕÚ"
    "àáâãçéêíóôõú"
)
pyftsubset \
    DejaVuSans.ttf \
    --output-file=DejaVuSans-Small-PTBR.temp.ttf \
    --unicodes="$(IFS=,; echo "${unicodes[*]}")" \
    --text="$(IFS= ; echo "${other_glyphs[*]}")" \
    --layout-features="" \
    --no-hinting \
    --desubroutinize \
    --no-layout-closure \
    --no-ignore-missing-unicodes \
    --no-ignore-missing-glyphs

# 2) Rename the font family
ttx -q -o - DejaVuSans-Small-PTBR.temp.ttf \
    | sed -e 's/DejaVu Sans/DejaVu Sans Small PTBR/g' \
          -e 's/DejaVuSans/DejaVuSansSmallPTBR/g' \
    | ttx -q --no-recalc-timestamp -o DejaVuSans-Small-PTBR.ttf -

rm -f DejaVuSans-Small-PTBR.temp.ttf
