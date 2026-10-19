local M = {}

function M.open_file(path)
    path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
    if vim.fn.filereadable(path) ~= 1 then
        vim.notify("Cannot open file: " .. path, vim.log.levels.ERROR)
        return
    end

    local buffer = vim.fn.bufadd(path)
    vim.fn.bufload(buffer)

    local width = math.max(1, math.floor(vim.o.columns * 0.8))
    local height = math.max(1, math.floor(vim.o.lines * 0.8))
    local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1)
    local col = math.max(0, math.floor((vim.o.columns - width) / 2))

    return vim.api.nvim_open_win(buffer, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        border = "rounded",
        title = " " .. vim.fn.fnamemodify(path, ":~:.") .. " ",
        title_pos = "center",
        style = "minimal",
    })
end

return M
