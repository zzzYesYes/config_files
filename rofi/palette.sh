#!/bin/bash
# Command palette: searchable list of shortcuts and commands.
# Format per entry: description <TAB> keys <TAB> command (command optional).
# Selecting an entry runs its command (info-only entries do nothing).

entries=$(cat <<'EOF'
Terminal	SUPER+Enter	alacritty
File manager (yazi)	SUPER+E	alacritty -e yazi
App launcher	SUPER+R	rofi -show drun
Control center	SUPER+C	ags toggle control-center
Command palette	SUPER+P	
Notifications	SUPER+SHIFT+N	swaync-client -t
Bluetooth on/off	SUPER+B	/home/zzz/.config/hypr/scripts/toggle-bluetooth.sh
Bluetooth devices	SUPER+SHIFT+B	/home/zzz/.config/waybar/bt-menu.sh
Logout menu	SUPER+SHIFT+D	wlogout
Lock screen	via logout menu	hyprlock
Pseudo tile window	SUPER+SHIFT+P	
Close window	SUPER+Q	
Float window	SUPER+V	
Focus left/down/up/right	SUPER+H/J/K/L	
Move window to workspace	SUPER+SHIFT+0-9	
Switch workspace	SUPER+0-9	
Toggle touchpad	SUPER+T	
Volume/brightness OSD	XF86 media keys	
yazi: sort files	, then n/a/s/m/b/e/r (capital = reverse)	
yazi: open image in imv (dir order)	Enter on image	
yazi: open video in mpv	Enter on video	
yazi: choose program	o	
imv: prev/next image	Left/Right	
imv: zoom	i/o or Up/Down	
imv: scaling mode	s / S	
mpv: next/previous video	Enter or > / <	
tmux: prefix	Ctrl+A	
tmux: split horizontal/vertical	prefix + | / -	
tmux: switch pane	M-h/j/k/l	
EOF
)

choice=$(printf '%s\n' "$entries" | awk -F'\t' '{printf "%-38s %s\n", $1, $2}' |
    rofi -dmenu -i -p "Palette")

[ -z "$choice" ] && exit 0

desc=$(printf '%s' "$choice" | sed 's/^\(.\{38\}\).*/\1/; s/ *$//')
cmd=$(printf '%s\n' "$entries" | awk -F'\t' -v d="$desc" '$1 == d {print $3}')

[ -n "$cmd" ] && exec $cmd
exit 0
