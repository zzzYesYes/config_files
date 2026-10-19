return {
    "nvimtools/hydra.nvim",
    config = function()
        local Hydra = require("hydra")

        Hydra({
            name = "Resize Window",
            mode = "n",
            body = "<leader>hr",
            hint = [[
   Move Split Divider

       _k_: up
 _h_: left      _l_: right
       _j_: down

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
                { "h", function() require("config.resize").move_divider("h") end, { desc = "Move divider left" } },
                { "j", function() require("config.resize").move_divider("j") end, { desc = "Move divider down" } },
                { "k", function() require("config.resize").move_divider("k") end, { desc = "Move divider up" } },
                { "l", function() require("config.resize").move_divider("l") end, { desc = "Move divider right" } },
                { "q", nil, { exit = true, desc = "Exit" } },
                { "<Esc>", nil, { exit = true, desc = false } },
            },
        })
    end,
}
