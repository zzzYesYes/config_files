#!/usr/bin/env lua
-- Bluetooth device menu for waybar (rofi).
-- Sections: Connected / Paired / New (discovered, not paired yet).
-- Clicking a device connects/disconnects/pairs it. Only active when BT is on.

local function shq(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function capture(cmd)
    local p = io.popen(cmd)
    local out = p:read("*a") or ""
    p:close()
    return (out:gsub("\n+$", ""))
end

local powered = capture("bluetoothctl show")
if not powered:find("Powered: yes", 1, true) then
    os.exit(0)
end

local rows, row_mac, row_act = {}, {}, {}

local function esc(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function addrow(row, mac, act)
    rows[#rows + 1] = row
    row_mac[#row_mac + 1] = mac
    row_act[#row_act + 1] = act
end

local function header(text)
    addrow("<span weight='bold' foreground='#c6a0f6'>" .. text .. "</span>", "", "")
end

local function separator()
    addrow("<span foreground='#494d64'>" .. string.rep(utf8.char(0x2500), 27) .. "</span>", "", "")
end

local function device_rows(list, icon, action) -- list = newline-joined "Device MAC name" lines
    local count = 0
    for line in list:gmatch("[^\n]+") do
        local mac, name = line:match("^Device (%S+) (.*)$")
        if mac then
            addrow("  " .. icon .. "  " .. esc(name), mac, action)
            count = count + 1
        end
    end
    if count == 0 then
        addrow("<span foreground='#6e738d' style='italic'>  (none)</span>", "", "")
    end
end

-- like comm -13/-23 on sorted inputs: sorted lines of `a` that are not in `b`
local function set_difference(a, b)
    local in_b = {}
    for line in b:gmatch("[^\n]+") do in_b[line] = true end
    local out = {}
    for line in a:gmatch("[^\n]+") do
        if not in_b[line] then out[#out + 1] = line end
    end
    table.sort(out)
    return table.concat(out, "\n")
end

local connected = capture("bluetoothctl devices Connected 2>/dev/null")
local paired = capture("bluetoothctl devices Paired 2>/dev/null")
local all = capture("bluetoothctl devices 2>/dev/null")

header(" Connected")
device_rows(connected, "", "disconnect")
separator()
header(" Paired")
device_rows(set_difference(paired, connected), "", "connect")
separator()
header(" New")
device_rows(set_difference(all, paired), "", "pair")
separator()
addrow("<span foreground='#8aadf4'>    Scan for new devices</span>", "", "scan")

if os.getenv("BT_MENU_DEBUG") then
    for _, row in ipairs(rows) do print(row) end
    os.exit(0)
end

local tmp = os.tmpname()
local f = assert(io.open(tmp, "w"))
for _, row in ipairs(rows) do f:write(row, "\n") end
f:close()
local p = io.popen("rofi -dmenu -i -markup-rows -format i -p '' -theme-str 'window { width: 420px; }' < " .. tmp)
local sel = p:read("*l") or ""
p:close()
os.remove(tmp)
if sel == "" then os.exit(0) end

local idx = tonumber(sel)
local action = idx and row_act[idx + 1] or ""
local mac = idx and row_mac[idx + 1] or ""

if action == "" then
    os.exit(0)
elseif action == "scan" then
    os.execute("bluetoothctl --timeout 5 scan on >/dev/null 2>&1")
    os.execute(shq(arg[0])) -- re-exec self to show refreshed list
elseif action == "disconnect" then
    os.execute("bluetoothctl disconnect " .. shq(mac))
elseif action == "connect" then
    os.execute("bluetoothctl connect " .. shq(mac))
elseif action == "pair" then
    os.execute("bluetoothctl pair " .. shq(mac))
    os.execute("bluetoothctl trust " .. shq(mac))
    os.execute("bluetoothctl connect " .. shq(mac))
end
