return {
    "startup-nvim/startup.nvim",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
        vim.g.startup_disable_on_startup = true
        require("config.dashboard").setup()
    end,
}
