#!/bin/bash
# Wifi network menu (rofi): scan, list SSIDs with signal strength,
# connect on selection (prompts for password if the network is new).

bar() { # $1 = signal 0-100
    local pct=$1 filled=$((pct / 10)) i out=""
    for ((i = 0; i < filled; i++)); do out+="█"; done
    for ((i = filled; i < 10; i++)); do out+="░"; done
    printf '%s' "$out"
}

# cached list shows instantly; the Rescan row refreshes on demand
if [ "$1" = "--rescan" ]; then
    nmcli device wifi rescan 2>/dev/null
    sleep 1
fi

menu=$(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list |
    grep -v '^:' | sort -t: -k2 -rn | awk -F: '!seen[$1]++' |
    while IFS=: read -r ssid signal security inuse; do
        [ -z "$ssid" ] && continue
        mark="  "; [ "$inuse" = "*" ] && mark="* "
        lock=""; [ -n "$security" ] && lock=" L"
        printf '%s%-28s %s %3s%%%s\n' "$mark" "$ssid" "$(bar "$signal")" "$signal" "$lock"
    done)

[ -z "$menu" ] && exit 0

eth=$(nmcli -t -f DEVICE,TYPE,STATE device status | awk -F: '$2 == "ethernet" {print $1 " (" $3 ")"}')

menu=">> Rescan...
>> Hidden network...
$menu"
[ -n "$eth" ] && menu="$menu
-- ethernet --
$eth"

choice=$(printf '%s\n' "$menu" | rofi -dmenu -i -p "Wifi" -theme-str 'window { width: 560px; }')
[ -z "$choice" ] && exit 0

if printf '%s' "$choice" | grep -q '^>> Rescan'; then
    exec "$0" --rescan
fi

# ethernet rows and section header are informational only
printf '%s' "$choice" | grep -qE '^-- |^enp|^eth|^eno' && exit 0

if printf '%s' "$choice" | grep -q '^>> Hidden'; then
    ssid=$(rofi -dmenu -p "Hidden SSID" -theme-str 'window { width: 420px; }')
    [ -z "$ssid" ] && exit 0
    pass=$(rofi -dmenu -password -p "Password (empty = open)" -theme-str 'window { width: 420px; }')
    if [ -n "$pass" ]; then
        nmcli device wifi connect "$ssid" password "$pass" hidden yes
    else
        nmcli device wifi connect "$ssid" hidden yes
    fi
    exit 0
fi

ssid=$(printf '%s' "$choice" | sed 's/^[* ] *//' | sed 's/^\(.\{28\}\).*/\1/; s/ *$//')
[ -z "$ssid" ] && exit 0

# already connected -> disconnect
if printf '%s' "$choice" | grep -q '^\*'; then
    nmcli connection down id "$ssid" 2>/dev/null || nmcli device disconnect wlan0 2>/dev/null
    exit 0
fi

# known connection -> just bring it up
if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
    nmcli connection up id "$ssid" && exit 0
fi

# new network -> ask password if secured
if printf '%s' "$choice" | grep -q ' L$'; then
    pass=$(rofi -dmenu -password -p "Password for $ssid" -theme-str 'window { width: 420px; }')
    [ -z "$pass" ] && exit 0
    nmcli device wifi connect "$ssid" password "$pass"
else
    nmcli device wifi connect "$ssid"
fi
