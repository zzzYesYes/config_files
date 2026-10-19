#!/bin/bash
# Toggle built-in touchpad (ThinkPad T480)
# Hyprland >= 0.55 with Lua config: `hyprctl keyword` is rejected and device
# state can't be read back, so we toggle via `hyprctl eval` (Lua) and track
# state in a per-session file ($XDG_RUNTIME_DIR resets on session restart,
# which matches the device defaulting back to enabled on config reload).

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/toggle-touchpad.state"

notify() {
    # hyprctl notify <icon> <time_ms> <color> <message...>
    hyprctl notify "$1" 1500 "rgb(33ccff)" "$2"
}

find_touchpad() {
    # Touchpads are pointers, listed under "mice:" (two-space indented names).
    hyprctl devices 2>/dev/null | grep -oP '^\s{2}\K.*' | grep -iE 'synaptics|elan|touchpad|ps/2' | head -n 1
}

D="$(find_touchpad)"
if [ -z "$D" ]; then
    notify 3 "Touchpad not found"
    exit 1
fi

if [ -f "$STATE_FILE" ]; then
    hyprctl eval "hl.device({ name = \"$D\", enabled = true })" || exit 1
    rm -f "$STATE_FILE"
    notify 5 "Touchpad enabled"
else
    hyprctl eval "hl.device({ name = \"$D\", enabled = false })" || exit 1
    echo "$D" > "$STATE_FILE"
    notify 0 "Touchpad disabled"
fi
