#!/bin/bash
maim -s -c 1,0,0,0.6 -p 10 --format=png /dev/stdout | xclip -selection clipboard -t image/png -i
