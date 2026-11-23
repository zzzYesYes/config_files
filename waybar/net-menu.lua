#!/usr/bin/env lua
-- Wifi network menu (rofi): cached list, signal bars, connect/disconnect.
-- Sections: actions / wifi networks / ethernet (informational).

local BLOCK = utf8.char(0x2588)
local SHADE = utf8.char(0x2591)

local function shq(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function capture(cmd)
    local p = io.popen(cmd)
    local out = p:read("*a") or ""
    p:close()
    return (out:gsub("\n+$", ""))
end

local function bar_markup(pct) -- signal 0-100 -> colored bar (mauve filled, dim empty)
    local filled = pct // 10
    local f = string.rep(BLOCK, filled)
    local e = string.rep(SHADE, 10 - filled)
    return "<span font_family='3270 Nerd Font' foreground='#cba6f7'>" .. f ..
        "</span><span font_family='3270 Nerd Font' foreground='#45475a'>" .. e .. "</span>"
end

local function esc(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function rofi_prompt(opts) -- free-text prompt, returns typed text ("" on cancel)
    local p = io.popen("rofi -dmenu " .. opts)
    local out = p:read("*l") or ""
    p:close()
    return out
end

if arg[1] == "--rescan" then
    os.execute("nmcli device wifi rescan 2>/dev/null")
    os.execute("sleep 1")
end

local rows, acts = {}, {}

local function add(row, act)
    rows[#rows + 1] = row
    acts[#acts + 1] = act
end

add(">> Rescan...", "rescan")
add(">> Hidden network...", "hidden")

local wifi = capture("nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list --rescan no")
local nets = {}
for line in wifi:gmatch("[^\n]+") do
    if line:sub(1, 1) ~= ":" then
        local ssid, signal, security, inuse = line:match("^([^:]*):([^:]*):([^:]*):(.*)$")
        if ssid then
            nets[#nets + 1] = { line = line, ssid = ssid, signal = tonumber(signal) or 0,
                signal_str = signal, security = security, inuse = inuse }
        end
    end
end
-- sort -t: -k2 -rn: signal descending, whole line as tiebreak (GNU sort default)
table.sort(nets, function(a, b)
    if a.signal ~= b.signal then return a.signal > b.signal end
    return a.line < b.line
end)

local seen = {}
for _, n in ipairs(nets) do
    if n.ssid ~= "" and not seen[n.ssid] then
        seen[n.ssid] = true
        local mark = (n.inuse == "*") and "* " or "  "
        local lock = (n.security ~= "") and " L" or ""
        add(string.format("%s%-28s %s %3s%%%s", mark, esc(n.ssid), bar_markup(n.signal), n.signal_str, lock),
            "ssid:" .. n.ssid .. ":" .. n.inuse)
    end
end

local eth = {}
local status = capture("nmcli -t -f DEVICE,TYPE,STATE device status")
for line in status:gmatch("[^\n]+") do
    local dev, typ, state = line:match("^([^:]*):([^:]*):([^:]*)")
    if typ == "ethernet" then
        eth[#eth + 1] = dev .. " (" .. state .. ")"
    end
end
if #eth > 0 then
    add("-- ethernet --", "noop")
    for _, line in ipairs(eth) do add(line, "noop") end
end

local tmp = os.tmpname()
local f = assert(io.open(tmp, "w"))
for _, row in ipairs(rows) do f:write(row, "\n") end
f:close()
local p = io.popen("rofi -dmenu -i -markup-rows -format i -p 'Wifi' -theme-str 'window { width: 620px; }' < " .. tmp)
local sel = p:read("*l") or ""
p:close()
os.remove(tmp)
if sel == "" then os.exit(0) end

local action = acts[tonumber(sel) + 1] or "noop"

if action == "noop" then
    os.exit(0)
elseif action == "rescan" then
    os.execute(shq(arg[0]) .. " --rescan")
    os.exit(0)
elseif action == "hidden" then
    local ssid = rofi_prompt("-p 'Hidden SSID' -theme-str 'window { width: 420px; }'")
    if ssid == "" then os.exit(0) end
    local pass = rofi_prompt("-password -p 'Password (empty = open)' -theme-str 'window { width: 420px; }'")
    if pass ~= "" then
        os.execute("nmcli device wifi connect " .. shq(ssid) .. " password " .. shq(pass) .. " hidden yes")
    else
        os.execute("nmcli device wifi connect " .. shq(ssid) .. " hidden yes")
    end
    os.exit(0)
end

-- action = "ssid:<ssid>:<inuse>"
local rest = action:sub(6)
local inuse = rest:match("([^:]*)$")
local ssid = rest:sub(1, #rest - #inuse - 1)

if inuse == "*" then
    os.execute("nmcli connection down id " .. shq(ssid) .. " 2>/dev/null")
    os.exit(0)
end

local known = false
for line in capture("nmcli -t -f NAME connection show"):gmatch("[^\n]+") do
    if line == ssid then
        known = true
        break
    end
end
if known and os.execute("nmcli connection up id " .. shq(ssid)) then
    os.exit(0)
end

local wpa = false
for line in capture("nmcli -t -f SSID,SECURITY dev wifi list --rescan no"):gmatch("[^\n]+") do
    if line:sub(1, #ssid + 1) == ssid .. ":" and line:find("WPA", #ssid + 2, true) then
        wpa = true
        break
    end
end
if wpa then
    local pass = rofi_prompt("-password -p " .. shq("Password for " .. ssid) .. " -theme-str 'window { width: 420px; }'")
    if pass == "" then os.exit(0) end
    os.execute("nmcli device wifi connect " .. shq(ssid) .. " password " .. shq(pass))
else
    os.execute("nmcli device wifi connect " .. shq(ssid))
end
