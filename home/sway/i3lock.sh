#!/bin/bash

img="$HOME/.cache/i3lock.png"

# Take a screenshot for our background
scrot $img
# Pixelate the background
convert $img -scale 10% -scale 1000% $img
# Finally run i3lock itself
i3lock -u -i $img
