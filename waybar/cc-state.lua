#!/usr/bin/env lua
-- Waybar custom module: gear icon, "active" class while the control center is visible.

local gear = utf8.char(0xf1de)

local content = ""
local f = io.open("/tmp/cc-visible", "r")
if f then
    content = f:read("*a") or ""
    f:close()
end
content = content:gsub("\n+$", "")

if content == "1" then
    print(string.format('{"text": "%s", "class": "active"}', gear))
else
    print(string.format('{"text": "%s"}', gear))
end
