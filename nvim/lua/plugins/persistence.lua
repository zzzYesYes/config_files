return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
        options = { "buffers", "curdir", "tabpages", "winsize" },
    },
}
