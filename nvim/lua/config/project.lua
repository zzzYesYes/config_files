local M = {}

local startup_dir = vim.uv.cwd()
local opened_directory = false

for _, arg in ipairs(vim.fn.argv()) do
    local path = vim.fs.normalize(vim.fn.fnamemodify(arg, ":p"))
    if vim.fn.isdirectory(path) == 1 then
        startup_dir = path
        opened_directory = true
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
    require("neo-tree.command").execute({
        action = "toggle",
        source = "filesystem",
        position = "left",
        dir = M.root(),
        reveal = true,
    })
end

function M.cd()
    vim.api.nvim_set_current_dir(M.root())
end

if opened_directory then
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        once = true,
        callback = function()
            vim.schedule(function()
                require("neo-tree.command").execute({
                    action = "focus",
                    source = "filesystem",
                    position = "left",
                    dir = M.root(),
                })
            end)
        end,
    })
end

return M
