vim.opt.termguicolors = true
local project = require("config.project")
project.cd()
require("config.options")
require("config.lazy")
project.open_dashboard()
require("config.lsp")
require("config.keymaps")
require("config.cmp")
