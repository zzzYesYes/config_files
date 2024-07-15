return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  event = "BufRead",
  opts = {
    close_if_last_window = true,
    buffers = {
      follow_current_file = {
	enabled = true,
      },
    },
    filesystem = {
      follow_current_file = {
	enabled = true,
      },
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
    },
  },
}
