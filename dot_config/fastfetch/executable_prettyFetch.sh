#!/bin/bash

LOGO_DIR="$HOME/Pictures/Fetch"

FASTFETCH_RANDOM_LOGO=$(find "$LOGO_DIR" -type f ! -name ".gitkeep" | shuf -n 1)

fastfetch --logo "$FASTFETCH_RANDOM_LOGO" --logo-height 20 --logo-width 40