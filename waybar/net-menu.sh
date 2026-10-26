#!/bin/bash
# Wifi network menu (rofi): cached list, signal bars, connect/disconnect.
# Sections: actions / wifi networks / ethernet (informational).

bar_markup() { # $1 = signal 0-100 -> colored bar (mauve filled, dim empty)
    local pct=$1
    local filled=$((pct / 10)) i f="" e=""
    for ((i = 0; i < filled; i++)); do f+="█"; done
    for ((i = filled; i < 10; i++)); do e+="░"; done
    printf "<span font_family='3270 Nerd Font' foreground='#cba6f7'>%s</span><span font_family='3270 Nerd Font' foreground='#45475a'>%s</span>" "$f" "$e"
}

esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

if [ "$1" = "--rescan" ]; then
    nmcli device wifi rescan 2>/dev/null
    sleep 1
fi

ROWS=()
ACT=()

add() { ROWS+=("$1"); ACT+=("$2"); }

add ">> Rescan..." "rescan"
add ">> Hidden network..." "hidden"

while IFS=: read -r ssid signal security inuse; do
    [ -z "$ssid" ] && continue
    mark="  "; [ "$inuse" = "*" ] && mark="* "
    lock=""; [ -n "$security" ] && lock=" L"
    add "$(printf '%s%-28s %s %3s%%%s' "$mark" "$(esc "$ssid")" "$(bar_markup "$signal")" "$signal" "$lock")" "ssid:$ssid:$inuse"
done < <(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list --rescan no | grep -v '^:' | sort -t: -k2 -rn | awk -F: '!seen[$1]++')

eth=$(nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2 == "ethernet" {print $1 " (" $3 ")"}')
if [ -n "$eth" ]; then
    add "-- ethernet --" "noop"
    while IFS= read -r line; do add "$line" "noop"; done <<< "$eth"
fi

sel=$(printf '%s\n' "${ROWS[@]}" | rofi -dmenu -i -markup-rows -format i -p "Wifi" -theme-str 'window { width: 620px; }')
[ -z "$sel" ] && exit 0
action=${ACT[$sel]}

case "$action" in
    noop)  exit 0 ;;
    rescan) exec "$0" --rescan ;;
    hidden)
        ssid=$(rofi -dmenu -p "Hidden SSID" -theme-str 'window { width: 420px; }')
        [ -z "$ssid" ] && exit 0
        pass=$(rofi -dmenu -password -p "Password (empty = open)" -theme-str 'window { width: 420px; }')
        if [ -n "$pass" ]; then
            nmcli device wifi connect "$ssid" password "$pass" hidden yes
        else
            nmcli device wifi connect "$ssid" hidden yes
        fi
        exit 0 ;;
esac

ssid=${action#ssid:}; inuse=${action##*:}; ssid=${ssid%:*}

if [ "$inuse" = "*" ]; then
    nmcli connection down id "$ssid" 2>/dev/null
    exit 0
fi

if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
    nmcli connection up id "$ssid" && exit 0
fi

if nmcli -t -f SSID,SECURITY dev wifi list --rescan no | grep -q "^$ssid:.*WPA"; then
    pass=$(rofi -dmenu -password -p "Password for $ssid" -theme-str 'window { width: 420px; }')
    [ -z "$pass" ] && exit 0
    nmcli device wifi connect "$ssid" password "$pass"
else
    nmcli device wifi connect "$ssid"
fi
