#!/bin/bash
# Sound/brightness menu for waybar: display-only block bars in rofi,
# select a row to pick a preset level.

bar() { # $1 = percent 0-100
    local pct=$1 filled=$((pct / 10)) i
    local out=""
    for ((i = 0; i < filled; i++)); do out+="█"; done
    for ((i = filled; i < 10; i++)); do out+="░"; done
    printf '%s' "$out"
}

get_levels() {
    OUT_PCT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
    OUT_MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo " (muted)" || true)
    IN_PCT=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{printf "%d", $2 * 100}')
    IN_MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo " (muted)" || true)
    BRI_PCT=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
}

pick_level() { # $1 = title -> prints chosen percent
    local levels="" i
    for ((i = 0; i <= 100; i += 10)); do
        levels+="$(printf '%3d%%  %s\n' "$i" "$(bar $i)")"
    done
    printf '%s' "$levels" | rofi -dmenu -i -p "$1" | awk '{print $1}' | tr -d '%'
}

while true; do
    get_levels
    menu=$(printf 'OUT %s %3d%%%s\nMIC %s %3d%%%s\nSUN %s %3d%%\n' \
        "$(bar "$OUT_PCT")" "$OUT_PCT" "$OUT_MUTE" \
        "$(bar "$IN_PCT")" "$IN_PCT" "$IN_MUTE" \
        "$(bar "$BRI_PCT")" "$BRI_PCT")

    sel=$(printf '%s' "$menu" | rofi -dmenu -i -format i -p "Sound")
    [ -z "$sel" ] && exit 0

    case $sel in
        0) lvl=$(pick_level "Output");   [ -n "$lvl" ] && wpctl set-volume @DEFAULT_AUDIO_SINK@ "${lvl}%";;
        1) lvl=$(pick_level "Input");    [ -n "$lvl" ] && wpctl set-volume @DEFAULT_AUDIO_SOURCE@ "${lvl}%";;
        2) lvl=$(pick_level "Brightness"); [ -n "$lvl" ] && brightnessctl set "${lvl}%";;
    esac
    [ -z "$lvl" ] && exit 0
done
