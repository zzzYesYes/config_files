-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.plugins = {
  {'dracula/vim'},
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        buffers = {
          follow_current_file = true,
        },
        filesystem = {
          follow_current_file = true,
          filtered_items = {
            visible = false,
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_by_name = {
              "node_modules"
            },
            never_show = {
              ".DS_Store",
              "thumbs.db"
            },
            always_show = {
              ".gitignored",
            },
            always_show_by_pattern = {
              ".env*",
            }
          },
        },
        window = {
          width = 30,
          mappings = {
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["D"] = "fuzzy_finder_directory",
            ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
            -- ["D"] = "fuzzy_sorter_directory",
            ["f"] = "filter_on_submit",
            ["<c-x>"] = "clear_filter",
            ["[g"] = "prev_git_modified",
            ["]g"] = "next_git_modified",
            ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
          }
        }
      })
    end
  },
  {
    'wfxr/minimap.vim',
    build = "cargo install --locked code-minimap",
    -- cmd = {"Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight"},
    config = function ()
      vim.cmd ("let g:minimap_width = 20")
      vim.cmd ("let g:minimap_highlight_search = 1")
    end,
  },
}

lvim.colorscheme = "dracula"
lvim.transparent_window = true
lvim.builtin.nvimtree.active = false -- NOTE: using neo-tree
lvim.builtin.which_key.mappings["e"] = {
  "<Cmd>Neotree toggle<CR>", "Explorer"
}
lvim.builtin.which_key.mappings["m"] = {
  name = "Minimap",
  m = { "<cmd>MinimapToggle<cr>", "Toggle" },
  r = { "<cmd>MinimapRefresh<cr>", "Refresh" },
}
