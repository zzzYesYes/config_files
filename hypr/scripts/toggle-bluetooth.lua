#!/usr/bin/env lua
-- Toggle bluetooth power.

local p = io.popen("bluetoothctl show")
local out = p:read("*a") or ""
p:close()

if out:find("Powered: yes", 1, true) then
    os.execute("bluetoothctl power off")
else
    os.execute("bluetoothctl power on")
end
