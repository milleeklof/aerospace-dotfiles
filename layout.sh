#!/bin/bash
AS=/opt/homebrew/bin/aerospace # Intel-Mac: /usr/local/bin/aerospace
PRESET_WS=5

# Hemworkspace per app. Justera bundle-id:n efter din egen lista.
home_ws() {
  case "$1" in
  com.apple.iCal) echo C ;;
  com.apple.mail) echo M ;;
  net.ankiweb.dtop) echo A ;;
  com.anthropic.claudefordesktop) echo I ;;
  com.vivaldi.Vivaldi) echo V ;;
  com.brave.Browser) echo B ;;
  com.hnc.Discord) echo D ;;
  notion.id) echo N ;;
  md.obsidian) echo O ;;
  com.mitchellh.ghostty) echo G ;;
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
      # 1 och G är flytande utanför presets
      case "$ws" in 1 | G) $AS layout --window-id "$id" floating ;; esac
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

# Gör fönstret bredare än 50/50 (ca 2/3) i en tvåkolumnslayout
widen() {
  local id W
  id=$($AS list-windows --workspace "$PRESET_WS" --format '%{window-id}|%{app-bundle-id}' | awk -F'|' -v b="$1" '$2==b {print $1; exit}')
  [ -z "$id" ] && return
  [ "$($AS list-windows --workspace "$PRESET_WS" --count)" -ge 2 ] || return
  W=$(osascript -e 'tell application "Finder" to get bounds of window of desktop' | awk -F', ' '{print $3}')
  $AS resize --window-id "$id" width +$((W / 6))
}

first_window_in_ws() {
  $AS list-windows --workspace "$PRESET_WS" --format '%{window-id}' | head -1
}

case "$1" in
work1) place com.mitchellh.ghostty com.anthropic.claudefordesktop; widen com.mitchellh.ghostty ;;
work2) place com.vivaldi.Vivaldi md.obsidian com.anthropic.claudefordesktop ;;
work3) place md.obsidian info.sioyek.sioyek com.anthropic.claudefordesktop ;;
restore)
  restore
  $AS workspace 1
  ;;
esac
