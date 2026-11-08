#!/usr/bin/env bash

# timer - audible timer: sleep, then send a desktop notification and play a sound
# Usage: timer 5m   (any GNU sleep duration: 30, 90s, 5m, 1h)
# pw-play is from pipewire-bin, notify-send from libnotify-bin
timer() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: timer <duration>  (e.g. 30s, 5m, 1h)" >&2
    return 1
  fi
  sleep "$1" || return
  notify-send "Timer done" "$1 elapsed"
  pw-play /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
}
