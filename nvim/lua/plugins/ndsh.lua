return {
    "zzzYesYes/ndsh",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        require("ndsh").setup({
            keys = {
                toggle = "<leader>ant",
                sessions = "<leader>ans",
                messages = "<leader>anm",
                resume = "<leader>anr",
                model = "<leader>anM",
                reasoning = "<leader>ane",
                new_session = false, -- create sessions with /new instead
            },
        })

        require("which-key").add({
            { "<leader>an", group = "ndsh" },
            { "<leader>ant", desc = "Toggle ndsh panel" },
            { "<leader>ans", desc = "Search ndsh sessions" },
            { "<leader>anm", desc = "Scan ndsh messages" },
            { "<leader>anr", desc = "Resume last ndsh session" },
            { "<leader>anM", desc = "Select ndsh model" },
            { "<leader>ane", desc = "Select reasoning effort" },
        })
    end,
}
