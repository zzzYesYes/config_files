return {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
        require("Comment").setup({
            pre_hook = function(ctx)
                return require("Comment.ft").get(
                    vim.bo.filetype,
                    ctx.ctype
                )
            end,
        })
    end,
}
