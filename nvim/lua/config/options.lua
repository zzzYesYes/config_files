vim.o.acd = false
vim.o.et = true
vim.o.nu = true
vim.o.rnu = true
vim.o.sta = true
vim.o.sw = 4
vim.o.wrap = false
vim.o.scl = "no"
vim.opt.tabstop = 4

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
            return
        end

        vim.api.nvim_set_option_value("number", true, { win = 0 })
        vim.api.nvim_set_option_value("relativenumber", true, { win = 0 })
    end,
})

--[[ vim.o.cc = "75"
vim.opt.list = true
vim.opt.listchars:append("space:·")
vim.opt.listchars:append("tab:»·") ]]
