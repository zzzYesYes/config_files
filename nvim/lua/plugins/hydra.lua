return {
    "nvimtools/hydra.nvim",
    config = function()
        local Hydra = require("hydra")

        Hydra({
            name = "Resize Window",
            mode = "n",
            body = "<leader>hr",
            hint = [[
   Resize Window

       _k_: taller
 _h_: narrower  _l_: wider
       _j_: shorter

 _q_ or _<Esc>_: exit
]],
            config = {
                color = "red",
                invoke_on_body = true,
                desc = "Resize window",
                hint = {
                    type = "window",
                    position = "bottom",
                    float_opts = { border = "rounded" },
                },
            },
            heads = {
                { "h", "<cmd>vertical resize -2<cr>", { desc = "Narrower" } },
                { "j", "<cmd>resize -2<cr>", { desc = "Shorter" } },
                { "k", "<cmd>resize +2<cr>", { desc = "Taller" } },
                { "l", "<cmd>vertical resize +2<cr>", { desc = "Wider" } },
                { "q", nil, { exit = true, desc = "Exit" } },
                { "<Esc>", nil, { exit = true, desc = false } },
            },
        })
    end,
}
