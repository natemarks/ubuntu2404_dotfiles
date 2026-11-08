#!/usr/bin/env bash

# timer - audible timer registered as a systemd user timer
# Runs independently of the shell, so it survives closing the terminal and is
# visible from any shell via `timers`.
# Usage: timer [<duration> [label]]   (no arguments lists pending timers; e.g. timer 5m tea; duration is a systemd time span: 30s, 5m, 1h)
# Cancel: timer_cancel <label>   (prefix match on the label given to timer)
# pw-play is from pipewire-bin, notify-send from libnotify-bin
timer() {
  # no arguments: show pending timers plus usage instead of failing
  if [[ $# -eq 0 ]]; then
    timers
    echo "Usage: timer <duration> [label]  (e.g. 5m tea); cancel with: timer_cancel <label>"
    return 0
  fi
  if [[ $# -gt 2 ]]; then
    echo "Usage: timer <duration> [label]  (e.g. 5m tea)" >&2
    return 1
  fi
  local duration="$1"
  local label="${2:-timer}"
  local unit
  # epoch + $RANDOM suffix keeps unit names unique so repeated labels don't collide
  # non-alphanumerics become '-' so unit names stay readable
  unit="timer-${label//[^[:alnum:]]/-}-$(date +%s)-${RANDOM}"
  # label is passed as $1 (not interpolated) so it can't be parsed as shell code,
  # hence the intentional single quotes
  # shellcheck disable=SC2016
  systemd-run --user --quiet --unit="${unit}" --on-active="${duration}" \
    bash -c 'notify-send "Timer done" "$1"; pw-play /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga' _ "${label} (${duration})" ||
    return
  echo "Timer set: ${label} (${duration}) as ${unit}.timer"
}

# timers - list pending timers with time remaining
timers() {
  if [[ -z "$(systemctl --user list-timers --no-legend --no-pager 'timer-*')" ]]; then
    echo "No timers pending"
    return 0
  fi
  systemctl --user list-timers --no-pager 'timer-*'
}

# timer_cancel - cancel pending timers whose label starts with the given text
timer_cancel() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: timer_cancel <label>" >&2
    return 1
  fi
  local prefix="timer-${1//[^[:alnum:]]/-}"
  local -a units
  mapfile -t units < <(systemctl --user list-units --type=timer --no-legend --plain "${prefix}*" | awk '{print $1}')
  if [[ ${#units[@]} -eq 0 ]]; then
    echo "No timer matching '$1'" >&2
    return 1
  fi
  systemctl --user stop "${units[@]}"
}
