local M = {}

local startup_dir = vim.uv.cwd()
local opened_directory = false
local show_dashboard = vim.fn.argc() == 0

for _, arg in ipairs(vim.fn.argv()) do
    local path = vim.fs.normalize(vim.fn.fnamemodify(arg, ":p"))
    if vim.fn.isdirectory(path) == 1 then
        startup_dir = path
        opened_directory = true
        show_dashboard = true
        break
    end
end

local function buffer_path()
    local name = vim.api.nvim_buf_get_name(0)
    if name == "" or vim.bo.buftype ~= "" then
        return nil
    end

    return vim.fs.normalize(name)
end

function M.root()
    local path = buffer_path() or startup_dir
    local git_root = vim.fs.root(path, ".git")

    return git_root or startup_dir
end

function M.find_files()
    require("telescope.builtin").find_files({ cwd = M.root() })
end

function M.live_grep()
    require("telescope.builtin").live_grep({ cwd = M.root() })
end

function M.file_browser()
    require("telescope").extensions.file_browser.file_browser({
        cwd = M.root(),
        path = M.root(),
    })
end

function M.neo_tree()
    local manager = require("neo-tree.sources.manager")
    local state = manager.get_state("filesystem")
    local is_open = state and state.winid and vim.api.nvim_win_is_valid(state.winid)

    require("neo-tree.command").execute({
        action = is_open and "close" or "show",
        source = "filesystem",
        position = "left",
        dir = M.root(),
        reveal = not is_open,
    })
end

function M.cd()
    vim.api.nvim_set_current_dir(M.root())
end

if opened_directory then
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
end

if show_dashboard then
    vim.schedule(function()
        require("config.dashboard").open()
    end)
end

return M
