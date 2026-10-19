local M = {}

local unicode_logo = {
    "███████╗███████╗███████╗",
    "╚══███╔╝╚══███╔╝╚══███╔╝",
    "  ███╔╝   ███╔╝   ███╔╝ ",
    " ███╔╝   ███╔╝   ███╔╝  ",
    "███████╗███████╗███████╗",
    "╚══════╝╚══════╝╚══════╝",
}

local ascii_logo = {
    "ZZZZZZZ  ZZZZZZZ  ZZZZZZZ",
    "    ZZ       ZZ       ZZ  ",
    "   ZZ       ZZ       ZZ   ",
    "  ZZ       ZZ       ZZ    ",
    " ZZZZZZZ  ZZZZZZZ  ZZZZZZZ",
}

local function pad_lines(lines)
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end

    for index, line in ipairs(lines) do
        lines[index] = line .. string.rep(" ", width - vim.fn.strdisplaywidth(line))
    end

    return lines
end

local function has_cowsay()
    return vim.fn.executable("fortune") == 1 and vim.fn.executable("cowsay") == 1
end

local function request_cowsay(callback)
    if not has_cowsay() then
        return
    end

    vim.system({ "fortune", "-s" }, { text = true }, function(fortune)
        if fortune.code ~= 0 or fortune.stdout == "" then
            return
        end

        vim.system({ "cowsay", "-W", "60" }, {
            stdin = fortune.stdout,
            text = true,
        }, function(cow)
            if cow.code ~= 0 or cow.stdout == "" then
                return
            end

            local lines = vim.split(vim.trim(cow.stdout), "\n", { plain = true })
            vim.schedule(function()
                callback(pad_lines(lines))
            end)
        end)
    end)
end

function M.header()
    if has_cowsay() then
        return {}
    end

    local has_unicode = vim.o.encoding == "utf-8" and vim.fn.strdisplaywidth("█") == 1
    return pad_lines(vim.deepcopy(has_unicode and unicode_logo or ascii_logo))
end

function M.project()
    return { require("config.project").root() }
end

function M.recenter(window)
    if not vim.api.nvim_win_is_valid(window) then
        return
    end

    local buffer = vim.api.nvim_win_get_buf(window)
    local content = vim.b[buffer].dashboard_content
    if vim.bo[buffer].filetype ~= "startup" or type(content) ~= "table" then
        return
    end

    content = vim.deepcopy(content)
    local width = vim.api.nvim_win_get_width(window)
    for index, line in ipairs(content) do
        local left_padding = math.max(0, math.floor((width - vim.fn.strdisplaywidth(line)) / 2))
        content[index] = string.rep(" ", left_padding) .. line
    end

    local height = vim.api.nvim_win_get_height(window)
    local top_padding = math.max(0, math.floor((height - #content) / 2) - 1)
    local lines = vim.fn['repeat']({ "" }, top_padding)
    vim.list_extend(lines, content)

    vim.api.nvim_set_option_value("modifiable", true, { buf = buffer })
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buffer })
end

function M.open()
    local previous_buffer = vim.api.nvim_get_current_buf()
    local buffer = vim.api.nvim_create_buf(false, true)
    local content = M.header()
    vim.list_extend(content, { "", require("config.project").root() })

    vim.b[buffer].dashboard_content = content
    vim.api.nvim_set_option_value("filetype", "startup", { buf = buffer })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buffer })
    vim.api.nvim_win_set_buf(0, buffer)

    if previous_buffer ~= buffer and vim.api.nvim_buf_is_valid(previous_buffer) then
        pcall(vim.api.nvim_buf_delete, previous_buffer, { force = true })
    end

    for _, option in ipairs({ "number", "relativenumber", "cursorline", "cursorcolumn", "list" }) do
        vim.api.nvim_set_option_value(option, false, { win = 0 })
    end
    vim.api.nvim_set_option_value("foldcolumn", "0", { win = 0 })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = 0 })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = 0 })
    M.recenter(vim.api.nvim_get_current_win())

    request_cowsay(function(header)
        if not vim.api.nvim_buf_is_valid(buffer) or vim.bo[buffer].filetype ~= "startup" then
            return
        end

        vim.list_extend(header, { "", require("config.project").root() })
        vim.b[buffer].dashboard_content = header
        for _, window in ipairs(vim.fn.win_findbuf(buffer)) do
            M.recenter(window)
        end
    end)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("dashboard", { clear = true })

    vim.api.nvim_create_autocmd("WinResized", {
        group = group,
        callback = function()
            local windows = vim.deepcopy(vim.v.event.windows or {})
            vim.schedule(function()
                for _, window in ipairs(windows) do
                    M.recenter(window)
                end
            end)
        end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(args)
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(args.buf)
                    or vim.api.nvim_get_current_buf() ~= args.buf
                    or not vim.b[args.buf].empty_buffer
                    or vim.bo[args.buf].modified
                then
                    return
                end

                M.open()
            end)
        end,
    })

    require("startup").setup({
        header = {
            type = "text",
            align = "center",
            fold_section = false,
            title = "",
            margin = 5,
            content = M.header,
            highlight = "Statement",
            default_color = "",
            oldfiles_amount = 0,
        },
        project = {
            type = "text",
            align = "center",
            fold_section = false,
            title = "",
            margin = 5,
            content = M.project,
            highlight = "Comment",
            default_color = "",
            oldfiles_amount = 0,
        },
        options = {
            mapping_keys = false,
            cursor_column = 0.5,
            empty_lines_between_mappings = false,
            disable_statuslines = true,
            paddings = { 2, 2 },
        },
        mappings = {
            execute_command = "<CR>",
            open_file = "o",
            open_file_split = "<C-o>",
            open_section = "<Tab>",
            open_help = "?",
        },
        colors = {
            background = "#1f2227",
            folded_section = "#56b6c2",
        },
        parts = { "header", "project" },
    })
end

return M
