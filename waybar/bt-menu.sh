#!/bin/bash
# Bluetooth device menu for waybar (rofi).
# Sections: Connected / Paired / New (discovered, not paired yet).
# Clicking a device connects/disconnects/pairs it. Only active when BT is on.

bluetoothctl show | grep -q "Powered: yes" || exit 0

ROWS=()
ROW_MAC=()
ROW_ACT=()

esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

header() {
    ROWS+=("<span weight='bold' foreground='#c6a0f6'>$1</span>")
    ROW_MAC+=(""); ROW_ACT+=("")
}

separator() {
    ROWS+=("<span foreground='#494d64'>───────────────────────────</span>")
    ROW_MAC+=(""); ROW_ACT+=("")
}

device_rows() { # $1 = device list (bluetoothctl output), $2 = icon, $3 = action
    local count=0 line mac name
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        mac=${line#Device }; mac=${mac%% *}
        name=$(esc "${line#Device "$mac" }")
        ROWS+=("  $2  $name")
        ROW_MAC+=("$mac"); ROW_ACT+=("$3")
        count=$((count + 1))
    done <<< "$1"
    if [ "$count" -eq 0 ]; then
        ROWS+=("<span foreground='#6e738d' style='italic'>  (none)</span>")
        ROW_MAC+=(""); ROW_ACT+=("")
    fi
}

connected=$(bluetoothctl devices Connected 2>/dev/null)
paired=$(bluetoothctl devices Paired 2>/dev/null)
all=$(bluetoothctl devices 2>/dev/null)
new=$(comm -13 <(printf '%s\n' "$paired" | sort) <(printf '%s\n' "$all" | sort))

header " Connected"
device_rows "$connected" "" "disconnect"
separator
header " Paired"
device_rows "$(comm -23 <(printf '%s\n' "$paired" | sort) <(printf '%s\n' "$connected" | sort))" "" "connect"
separator
header " New"
device_rows "$new" "" "pair"
separator
ROWS+=("<span foreground='#8aadf4'>    Scan for new devices</span>")
ROW_MAC+=(""); ROW_ACT+=("scan")

if [ -n "$BT_MENU_DEBUG" ]; then
    printf '%s\n' "${ROWS[@]}"
    exit 0
fi

sel=$(printf '%s\n' "${ROWS[@]}" | rofi -dmenu -i -markup-rows -format i \
    -p "" -theme-str 'window { width: 420px; }')
[ -z "$sel" ] && exit 0

action=${ROW_ACT[$sel]}
mac=${ROW_MAC[$sel]}

case "$action" in
    "")         exit 0 ;;
    scan)
        bluetoothctl --timeout 5 scan on >/dev/null 2>&1
        exec "$0" ;;
    disconnect) bluetoothctl disconnect "$mac" ;;
    connect)    bluetoothctl connect "$mac" ;;
    pair)
        bluetoothctl pair "$mac"
        bluetoothctl trust "$mac"
        bluetoothctl connect "$mac" ;;
esac
