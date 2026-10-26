#!/usr/bin/env lua
-- Toggle built-in touchpad (ThinkPad T480)
-- Hyprland >= 0.55 with Lua config: `hyprctl keyword` is rejected and device
-- state can't be read back, so we toggle via `hyprctl eval` (Lua) and track
-- state in a per-session file ($XDG_RUNTIME_DIR resets on session restart,
-- which matches the device defaulting back to enabled on config reload).

local STATE_FILE = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/toggle-touchpad.state"

local function notify(icon, msg)
    -- hyprctl notify <icon> <time_ms> <color> <message>
    os.execute(string.format("hyprctl notify %d 1500 'rgb(cba6f7)' '%s'", icon, msg))
end

local function find_touchpad()
    -- Touchpads are pointers, listed under "mice:" (two-space indented names).
    local p = io.popen("hyprctl devices 2>/dev/null")
    if not p then return nil end
    for line in p:lines() do
        local rest = line:match("^%s%s(.*)")
        if rest then
            local l = rest:lower()
            if l:find("synaptics", 1, true) or l:find("elan", 1, true)
                or l:find("touchpad", 1, true) or l:find("ps/2", 1, true) then
                p:close()
                return rest
            end
        end
    end
    p:close()
    return nil
end

local device = find_touchpad()
if not device or device == "" then
    notify(3, "Touchpad not found")
    os.exit(1)
end

local state = io.open(STATE_FILE, "r")
if state then
    state:close()
    if not os.execute(string.format('hyprctl eval "hl.device({ name = \\"%s\\", enabled = true })"', device)) then
        os.exit(1)
    end
    os.remove(STATE_FILE)
    notify(5, "Touchpad enabled")
else
    if not os.execute(string.format('hyprctl eval "hl.device({ name = \\"%s\\", enabled = false })"', device)) then
        os.exit(1)
    end
    local f = assert(io.open(STATE_FILE, "w"))
    f:write(device, "\n")
    f:close()
    notify(0, "Touchpad disabled")
end
