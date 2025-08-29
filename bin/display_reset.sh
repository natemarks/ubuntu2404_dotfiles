#!/usr/bin/env bash
set -Eeuo pipefail

#  to lok up the currently connected displays
# xrandr -q | egrep -v 'disconnected' | grep connected
#eDP-1 connected 1920x1080+0+1440 (normal left inverted right x axis y axis) 344mm x 193mm
#DP-1-1-6 connected primary 2560x1440+0+0 (normal left inverted right x axis y axis) 597mm x 336mm

# reset/wake the exteral display
xrandr -s 0

# reset display with external above internal
xrandr --output DP-1-1-6 --auto --primary && xrandr --output eDP-1 --auto --below DP-1-1-6