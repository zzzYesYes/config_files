local ensure_installed = {
    "bash",
    "c",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "rust",
    "ron",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
}

-- The "main" branch of nvim-treesitter needs the external tree-sitter CLI
-- to compile parsers. To make this config work out of the box on a new
-- machine, download a pinned prebuilt binary on first use if no CLI is
-- available on PATH. Cached in stdpath("data")/tree-sitter-cli/.
local TS_CLI_VERSION = "0.27.2"

local function cli_dir()
    return vim.fn.stdpath("data") .. "/tree-sitter-cli"
end

local function cli_path()
    local exe = vim.fn.has("win32") == 1 and "tree-sitter.exe" or "tree-sitter"
    return cli_dir() .. "/" .. exe
end

local function use_cached_cli()
    if vim.fn.executable(cli_path()) == 1 then
        vim.env.PATH = cli_dir() .. ":" .. vim.env.PATH
        return true
    end
    return false
end

local function ensure_cli(callback)
    if vim.fn.executable("tree-sitter") == 1 or use_cached_cli() then
        return callback(true)
    end

    local uname = vim.uv.os_uname()
    local os_name = ({ Linux = "linux", Darwin = "macos", Windows_NT = "windows" })[uname.sysname]
    local arch = ({ x86_64 = "x64", aarch64 = "arm64", arm64 = "arm64" })[uname.machine]
    if not os_name or not arch then
        vim.notify(
            "[nvim-treesitter] no prebuilt tree-sitter CLI for " .. uname.sysname .. "/" .. uname.machine,
            vim.log.levels.WARN
        )
        return callback(false)
    end

    local url = string.format(
        "https://github.com/tree-sitter/tree-sitter/releases/download/v%s/tree-sitter-%s-%s.gz",
        TS_CLI_VERSION,
        os_name,
        arch
    )
    local tmp = cli_dir() .. "/tree-sitter.gz"
    local dest = cli_path()
    vim.fn.mkdir(cli_dir(), "p")
    vim.notify("[nvim-treesitter] downloading tree-sitter CLI v" .. TS_CLI_VERSION .. " ...")

    local cmd = string.format(
        "curl -fsSL %q -o %q && gzip -dc %q > %q && chmod +x %q && rm -f %q",
        url, tmp, tmp, dest, dest, tmp
    )
    vim.system({ "sh", "-c", cmd }, {}, function(res)
        vim.schedule(function()
            if res.code == 0 and use_cached_cli() then
                callback(true)
            else
                vim.notify(
                    "[nvim-treesitter] failed to fetch tree-sitter CLI: " .. (res.stderr or "unknown error"),
                    vim.log.levels.ERROR
                )
                callback(false)
            end
        end)
    end)
end

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local treesitter = require("nvim-treesitter")

        ensure_cli(function(ok)
            if ok then
                treesitter.install(ensure_installed)
            else
                vim.notify(
                    "[nvim-treesitter] tree-sitter CLI unavailable; parsers not installed",
                    vim.log.levels.WARN
                )
            end
        end)

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match) or args.match
                if not vim.list_contains(ensure_installed, lang) then
                    return
                end

                if pcall(vim.treesitter.start, args.buf, lang) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
