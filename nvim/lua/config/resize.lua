local M = {}

local step = 2

local function neighbor(direction)
    local current = vim.fn.winnr()
    local target = vim.fn.winnr(direction)
    if target == current then
        return nil
    end

    return vim.fn.win_getid(target)
end

local function resize_window(window, vertical, amount)
    if not window or not vim.api.nvim_win_is_valid(window) then
        return
    end

    vim.api.nvim_win_call(window, function()
        local command = vertical and "vertical resize " or "resize "
        vim.cmd(command .. string.format("%+d", amount))
    end)
end

function M.move_divider(direction)
    local current = vim.api.nvim_get_current_win()

    if direction == "h" then
        local left = neighbor("h")
        if left then
            resize_window(left, true, -step)
        elseif neighbor("l") then
            resize_window(current, true, -step)
        end
    elseif direction == "l" then
        local right = neighbor("l")
        if right then
            resize_window(right, true, -step)
        elseif neighbor("h") then
            resize_window(current, true, -step)
        end
    elseif direction == "k" then
        local above = neighbor("k")
        if above then
            resize_window(above, false, -step)
        elseif neighbor("j") then
            resize_window(current, false, -step)
        end
    elseif direction == "j" then
        local below = neighbor("j")
        if below then
            resize_window(below, false, -step)
        elseif neighbor("k") then
            resize_window(current, false, -step)
        end
    end
end

return M
