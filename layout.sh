#!/bin/bash
AS=/opt/homebrew/bin/aerospace # Intel-Mac: /usr/local/bin/aerospace
PRESET_WS=5

# Hemworkspace per app. Justera bundle-id:n efter din egen lista.
home_ws() {
  case "$1" in
  com.apple.iCal) echo C ;;
  com.apple.mail) echo M ;;
  net.ankiweb.dtop) echo A ;;
  com.anthropic.claudefordesktop) echo 1 ;;
  com.vivaldi.Vivaldi) echo V ;;
  com.brave.Browser) echo B ;;
  com.hnc.Discord) echo D ;;
  notion.id) echo N ;;
  md.obsidian) echo O ;;
  com.mitchellh.ghostty) echo 1 ;;
  info.sioyek.sioyek) echo S ;;
  org.mozilla.firefox) echo F ;;
  com.apple.finder) echo 1 ;;
  com.apple.MobileSMS) echo 1 ;;
  com.apple.FaceTime) echo 1 ;;
  esac
}

restore() {
  $AS list-windows --all --format '%{window-id}|%{app-bundle-id}' | while IFS='|' read -r id bundle; do
    ws=$(home_ws "$bundle")
    if [ -n "$ws" ]; then
      $AS move-node-to-workspace --window-id "$id" "$ws"
      # På workspace 1 är Ghostty och Claude tilade, allt annat flytande
      if [ "$ws" = 1 ]; then
        case "$bundle" in
        com.mitchellh.ghostty | com.anthropic.claudefordesktop) $AS layout --window-id "$id" tiling ;;
        *) $AS layout --window-id "$id" floating ;;
        esac
      fi
    fi
  done
}

first_window() {
  $AS list-windows --monitor all --app-bundle-id "$1" --format '%{window-id}' | head -1
}

place() {
  restore
  for bundle in "$@"; do
    id=$(first_window "$bundle")
    if [ -z "$id" ]; then
      open -b "$bundle"
      for _ in $( # väntar max ca 10 sekunder
        seq 1 50
      ); do
        id=$(first_window "$bundle")
        [ -n "$id" ] && break
        sleep 0.2
      done
      sleep 0.3 # låter on-window-detected-regeln köra klart
    fi
    if [ -n "$id" ]; then
      $AS move-node-to-workspace --window-id "$id" "$PRESET_WS"
      $AS layout --window-id "$id" tiling
    fi
  done
  $AS flatten-workspace-tree --workspace "$PRESET_WS"
  first=$(first_window_in_ws)
  [ -n "$first" ] && $AS layout --window-id "$first" h_tiles
  $AS balance-sizes --workspace "$PRESET_WS"
  $AS workspace "$PRESET_WS"
}

first_window_in_ws() {
  $AS list-windows --workspace "$PRESET_WS" --format '%{window-id}' | head -1
}

# Workspace 1: Ghostty (vänster 2/3) och Claude (höger 1/3), tilade
home1() {
  g=$(first_window com.mitchellh.ghostty)
  c=$(first_window com.anthropic.claudefordesktop)
  for id in $g $c; do
    $AS move-node-to-workspace --window-id "$id" 1
    $AS layout --window-id "$id" tiling
  done
  $AS flatten-workspace-tree --workspace 1
  [ -n "$g" ] && $AS layout --window-id "$g" h_tiles
  $AS balance-sizes --workspace 1
  if [ -n "$g" ] && [ -n "$c" ]; then
    W=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | awk -F', ' '{print $3}')
    [ -n "$W" ] && $AS resize --window-id "$g" width +$((W / 6))
  fi
}

case "$1" in
work1) place com.vivaldi.Vivaldi com.mitchellh.ghostty com.anthropic.claudefordesktop ;;
work2) place com.vivaldi.Vivaldi md.obsidian com.anthropic.claudefordesktop ;;
work3) place md.obsidian info.sioyek.sioyek com.anthropic.claudefordesktop ;;
home1) home1 ;;
restore)
  restore
  home1
  $AS workspace 1
  ;;
esac
