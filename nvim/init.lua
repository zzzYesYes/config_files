vim.opt.termguicolors = true
require("config.project")
require("config.options")
require("config.lazy")
require("config.project").open_dashboard()
require("config.lsp")
require("config.keymaps")
require("config.cmp")
