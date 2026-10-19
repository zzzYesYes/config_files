local function open_selected_in_float(prompt_bufnr)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local from_entry = require("telescope.from_entry")
    local entry = action_state.get_selected_entry()
    local path = entry and from_entry.path(entry, true, false)

    if not path then
        return
    end

    actions.close(prompt_bufnr)
    require("config.float").open_file(path)
end

return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sharkdp/fd",
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            defaults = {
                mappings = {
                    i = {
                        ["<C-f>"] = open_selected_in_float,
                    },
                    n = {
                        ["<C-f>"] = open_selected_in_float,
                    },
                },
            },
        },
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
    },
}
