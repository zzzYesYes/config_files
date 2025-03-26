return {
    {
        "Mofiqul/dracula.nvim",
        lazy = true,
        opts = {
            transparent_bg = true,
        },
    },
    {
        "folke/tokyonight.nvim",
        lazy=true,
        opts = {
            style = "moon",
            transparent = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            }
        },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
            aerial = true,
            alpha = true,
            cmp = true,
            fzf = true,
            leap = true,
            neotree = true,
            treesitter = true,
            telescope = true,
            which_key = true,
            mason = true,
            headlines = true,
        }
    }
}
