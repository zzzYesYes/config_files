--- @sync entry

local IMAGE_EXTS = {
	png = true, jpg = true, jpeg = true, gif = true, bmp = true,
	webp = true, tif = true, tiff = true, avif = true, heic = true,
	heif = true, qoi = true, svg = true, jxl = true,
}

local function is_image(file)
	local ext = file.url.ext
	return ext and IMAGE_EXTS[ext:lower()] or false
end

local function entry()
	local cur = cx.active.current
	local hovered = cur.hovered
	if not hovered or hovered.cha.is_dir or not is_image(hovered) then
		ya.emit("open", {})
		return
	end

	local list = {}
	for i = 1, #cur.files do
		local f = cur.files[i]
		if f and not f.cha.is_dir and is_image(f) then
			list[#list + 1] = tostring(f.url)
		end
	end

	if #list == 0 then
		ya.emit("open", {})
		return
	end

	local cmd = Command("imv"):arg("-n"):arg(tostring(hovered.url))
	for _, path in ipairs(list) do
		cmd:arg(path)
	end
	cmd:spawn()
end

return { entry = entry }
