#!/bin/bash
# Command palette with groups (rofi script modes, Ctrl+Tab / Ctrl+Shift+Tab to cycle).
#
# Usage:
#   palette.sh                 -> launch rofi with all groups
#   palette.sh <group>         -> print entries of a group (rofi calls this)
#   palette.sh <group> <sel>   -> a row was selected: run its command
#
# Entry format: description <TAB> keys <TAB> command (command may be empty).
# The Hyprland group is parsed live from hyprland.lua; the rest are curated.

HYPRLAND_LUA="/home/zzz/.config/hypr/hyprland.lua"

hyprland_entries() {
    python3 - "$HYPRLAND_LUA" <<'PY'
import re, sys

src = open(sys.argv[1]).read()

DISPATCHERS = {
    "hl.dsp.window.close()": "Close window",
    "hl.dsp.window.float({ action = \"toggle\" })": "Float window",
    "hl.dsp.window.pseudo()": "Pseudo tile",
    'hl.dsp.layout("togglesplit")': "Toggle split",
}

def clean_key(expr):
    expr = expr.replace("mainMod", "SUPER").replace(" .. ", "").replace('"', "")
    return expr.strip()

FRIENDLY = {
    "alacritty": "Terminal",
    "alacritty -e yazi": "File manager (yazi)",
    "rofi -show drun": "App launcher",
    "ags toggle control-center": "Control center",
    "/home/zzz/.config/rofi/palette.sh": "Command palette",
    "swaync-client -t": "Notifications",
    "/home/zzz/.config/hypr/scripts/toggle-bluetooth.sh": "Bluetooth on/off",
    "/home/zzz/.config/waybar/bt-menu.sh": "Bluetooth devices",
    "hyprlock": "Lock screen",
    "wlogout": "Logout menu",
    "firefox": "Firefox",
    "google-chrome-stable": "Chrome",
    "/home/zzz/.config/hypr/scripts/toggle-touchpad.sh": "Toggle touchpad",
}

vars = dict(re.findall(r'local (\w+)\s*=\s*"([^"]*)"', src))

rows = []
for line in src.splitlines():
    if line.strip().startswith("--"):
        continue  # skip commented-out binds
    m = re.search(r'hl\.bind\((.+?),\s*(hl\.dsp\..+?)\)(?:,\s*\{[^}]*\})?\s*$', line)
    if not m:
        continue
    keys, dsp = clean_key(m.group(1)), m.group(2)
    em = re.match(r'hl\.dsp\.exec_cmd\((.+)\)', dsp)
    if em:
        cmd = em.group(1).strip('"').strip("'")
        cmd = vars.get(cmd, cmd)  # resolve lua variables (terminal, menu, ...)
        if cmd.startswith(("swayosd-client", "brightnessctl", "playerctl")):
            continue  # covered by the static XF86 row
        desc = FRIENDLY.get(cmd, cmd.split("/")[-1].split()[0])
        rows.append((desc, keys, cmd))
    else:
        desc = DISPATCHERS.get(dsp)
        if desc:
            rows.append((desc, keys, ""))

rows.append(("Switch workspace", "SUPER+0-9", ""))
rows.append(("Move window to workspace", "SUPER+SHIFT+0-9", ""))
rows.append(("Focus pane", "SUPER+H/J/K/L", ""))
rows.append(("Media keys (volume/brightness OSD)", "XF86", ""))

for desc, keys, cmd in rows:
    print(f"{desc}\t{keys}\t{cmd}")
PY
}

static_entries() { # $1 = group name
    case "$1" in
        files) cat <<'EOF'
yazi: file manager	SUPER+E	alacritty -e yazi
yazi: sort files	, then n/a/s/m/b/e/r (capital = reverse)	
yazi: open image in imv	Enter on image	
yazi: open video in mpv	Enter on video	
yazi: choose program	o	
imv: prev/next image	Left/Right	
imv: zoom in/out	i/o or Up/Down	
imv: scaling mode	s / S	
mpv: next/previous	Enter or > / <	
mpv: next chapter	PgUp/PgDn	
EOF
            ;;
        tmux) cat <<'EOF'
tmux: prefix	Ctrl+A	
tmux: split horizontal	prefix + |	
tmux: split vertical	prefix + -	
tmux: switch pane	M-h/j/k/l	
tmux: switch window	M-0..9	
tmux: reload config	prefix + r	
EOF
            ;;
        system) cat <<'EOF'
Lock screen		hyprlock
Logout menu	SUPER+SHIFT+D	wlogout
Suspend	via logout menu	
Hibernate	via logout menu	
Bluetooth devices	SUPER+SHIFT+B	/home/zzz/.config/waybar/bt-menu.sh
Bluetooth on/off	SUPER+B	/home/zzz/.config/hypr/scripts/toggle-bluetooth.sh
EOF
            ;;
    esac
}

print_group() { # $1 = group
    if [ "$1" = "hyprland" ]; then
        hyprland_entries
    else
        static_entries "$1"
    fi
}

if [ $# -eq 0 ]; then
    # launcher mode
    exec rofi -show Hyprland \
        -modi "Hyprland:palette.sh hyprland,Files:palette.sh files,tmux:palette.sh tmux,System:palette.sh system" \
        -kb-mode-next "Control+Tab" -kb-mode-previous "Control+Shift+Tab" \
        -theme-str 'window { width: 620px; }'
fi

if [ $# -eq 1 ]; then
    print_group "$1" | awk -F'\t' '{printf "%-34s %s\n", $1, $2}'
    exit 0
fi

# selection: look up command by padded row text
sel="$2"
desc=$(printf '%s' "$sel" | sed 's/^\(.\{34\}\).*/\1/; s/ *$//')
cmd=$(print_group "$1" | awk -F'\t' -v d="$desc" '$1 == d {print $3}')
[ -n "$cmd" ] && nohup $cmd >/dev/null 2>&1 &
exit 0
