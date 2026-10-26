#!/usr/bin/env lua
-- Command palette with groups (rofi script modes, Ctrl+Tab / Ctrl+Shift+Tab to cycle).
--
-- Usage:
--   palette.lua                 -> launch rofi with all groups
--   palette.lua <group>         -> print entries of a group (rofi calls this)
--   palette.lua <group> <sel>   -> a row was selected: run its command
--
-- Entry format: description <TAB> keys <TAB> command (command may be empty).
-- The Hyprland group is parsed live from hyprland.lua; the rest are curated.

local HYPRLAND_LUA = "/home/zzz/.config/hypr/hyprland.lua"
local SELF = "/home/zzz/.config/rofi/palette.lua"

local DISPATCHERS = {
    ["hl.dsp.window.close()"] = "Close window",
    ['hl.dsp.window.float({ action = "toggle" })'] = "Float window",
    ["hl.dsp.window.pseudo()"] = "Pseudo tile",
    ['hl.dsp.layout("togglesplit")'] = "Toggle split",
}

local FRIENDLY = {
    ["alacritty"] = "Terminal",
    ["alacritty -e yazi"] = "File manager (yazi)",
    ["rofi -show drun"] = "App launcher",
    ["ags toggle control-center"] = "Control center",
    ["/home/zzz/.config/rofi/palette.lua"] = "Command palette",
    ["swaync-client -t"] = "Notifications",
    ["/home/zzz/.config/hypr/scripts/toggle-bluetooth.lua"] = "Bluetooth on/off",
    ["/home/zzz/.config/waybar/bt-menu.lua"] = "Bluetooth devices",
    ["hyprlock"] = "Lock screen",
    ["wlogout"] = "Logout menu",
    ["firefox"] = "Firefox",
    ["google-chrome-stable"] = "Chrome",
    ["/home/zzz/.config/hypr/scripts/toggle-touchpad.lua"] = "Toggle touchpad",
}

local function has_prefix(s, prefix)
    return s:sub(1, #prefix) == prefix
end

local function clean_key(expr)
    expr = expr:gsub("mainMod", "SUPER"):gsub(" %.%. ", ""):gsub('"', "")
    return (expr:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function hyprland_entries()
    local f = assert(io.open(HYPRLAND_LUA, "r"))
    local src = f:read("*a")
    f:close()

    local vars = {}
    for name, value in src:gmatch('local%s+(%w+)%s*=%s*"([^"]*)"') do
        vars[name] = value
    end

    local rows = {}
    for line in src:gmatch("[^\n]+") do
        if not line:match("^%s*%-%-") then -- skip commented-out binds
            local keys, dsp = line:match("hl%.bind%((.-),%s*(hl%.dsp%..*)")
            if dsp then
                dsp = dsp:gsub(",%s*{[^{}]*}%s*$", "") -- drop trailing options table
                dsp = dsp:match("^(.*)%)%s*$")        -- drop bind's closing paren
            end
            if dsp then
                keys = clean_key(keys)
                local cmdarg = dsp:match("^hl%.dsp%.exec_cmd%((.+)%)$")
                if cmdarg then
                    cmdarg = cmdarg:gsub('^"+', ""):gsub('"+$', ""):gsub("^'+", ""):gsub("'+$", "")
                    local cmd = vars[cmdarg] or cmdarg -- resolve lua variables (terminal, menu, ...)
                    if not (has_prefix(cmd, "swayosd-client") or has_prefix(cmd, "brightnessctl")
                        or has_prefix(cmd, "playerctl")) then
                        -- covered by the static XF86 row
                        local desc = FRIENDLY[cmd]
                        if not desc then
                            local base = cmd:match("([^/]*)$") or cmd
                            desc = base:match("%S+") or base
                        end
                        rows[#rows + 1] = { desc, keys, cmd }
                    end
                else
                    local desc = DISPATCHERS[dsp]
                    if desc then
                        rows[#rows + 1] = { desc, keys, "" }
                    end
                end
            end
        end
    end

    rows[#rows + 1] = { "Switch workspace", "SUPER+0-9", "" }
    rows[#rows + 1] = { "Move window to workspace", "SUPER+SHIFT+0-9", "" }
    rows[#rows + 1] = { "Focus pane", "SUPER+H/J/K/L", "" }
    rows[#rows + 1] = { "Media keys (volume/brightness OSD)", "XF86", "" }
    return rows
end

local STATIC = {
    files = {
        { "yazi: file manager", "SUPER+E", "alacritty -e yazi" },
        { "yazi: sort files", ", then n/a/s/m/b/e/r (capital = reverse)", "" },
        { "yazi: open image in imv", "Enter on image", "" },
        { "yazi: open video in mpv", "Enter on video", "" },
        { "yazi: choose program", "o", "" },
        { "imv: prev/next image", "Left/Right", "" },
        { "imv: zoom in/out", "i/o or Up/Down", "" },
        { "imv: scaling mode", "s / S", "" },
        { "mpv: next/previous", "Enter or > / <", "" },
        { "mpv: next chapter", "PgUp/PgDn", "" },
    },
    tmux = {
        { "tmux: prefix", "Ctrl+A", "" },
        { "tmux: split horizontal", "prefix + |", "" },
        { "tmux: split vertical", "prefix + -", "" },
        { "tmux: switch pane", "M-h/j/k/l", "" },
        { "tmux: switch window", "M-0..9", "" },
        { "tmux: reload config", "prefix + r", "" },
    },
    system = {
        { "Lock screen", "SUPER+SHIFT+L", "hyprlock" },
        { "Logout menu", "SUPER+SHIFT+D", "wlogout" },
        { "Suspend", "via logout menu", "" },
        { "Hibernate", "via logout menu", "" },
        { "Bluetooth devices", "SUPER+SHIFT+B", "/home/zzz/.config/waybar/bt-menu.lua" },
        { "Bluetooth on/off", "SUPER+B", "/home/zzz/.config/hypr/scripts/toggle-bluetooth.lua" },
    },
}

local function group_entries(group)
    if group == "hyprland" then
        return hyprland_entries()
    end
    return STATIC[group] or {}
end

if #arg == 0 then
    -- launcher mode
    local modi = "Hyprland:" .. SELF .. " hyprland"
        .. ",Files:" .. SELF .. " files"
        .. ",tmux:" .. SELF .. " tmux"
        .. ",System:" .. SELF .. " system"
    local _, _, code = os.execute("rofi -show Hyprland"
        .. " -modi '" .. modi .. "'"
        .. " -kb-mode-next 'Shift+Right,Control+Tab'"
        .. " -kb-mode-previous 'Shift+Left,Control+ISO_Left_Tab'"
        .. " -theme-str 'window { width: 620px; }'")
    os.exit(code or 0)
end

if #arg == 1 then
    for _, e in ipairs(group_entries(arg[1])) do
        io.write(string.format("%-34s %s\n", e[1], e[2]))
    end
    os.exit(0)
end

-- selection: look up command by padded row text
local sel = arg[2]
local desc = sel:sub(1, 34):gsub(" +$", "")
for _, e in ipairs(group_entries(arg[1])) do
    if e[1] == desc and e[3] ~= "" then
        os.execute("nohup " .. e[3] .. " >/dev/null 2>&1 &")
    end
end
os.exit(0)
