local wk = require("which-key")
require("telescope.builtin")
require("telescope").load_extension("projects")

wk.register({
	l = {
		name = "Left Panel",
		e = { "<cmd>Neotree toggle<cr>", "File Explorer" },
		b = { function() print("hello") end, "Test function" },
	},
	r = {
		name = "Right Panel",
		s = { "<cmd>SymbolsOutline<cr>", "Symbols Outline" },
		m = { "<cmd>MinimapToggle<cr>", "Minimap" },
	},
	S = {
		name = "Session",
		c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
		l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
		Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
	},
	T = {
		name = "Uncommon Tools",
		l = { "<cmd>Lazy<cr>", "Lazy Nvim" },
		m = { "<cmd>Mason<cr>", "Mason" }
	},
	b = {
		name = "Bottom Panel",
		t = { "<cmd>TodoQuickFix<cr>", "Toggle todo list" },
	},
	t = {
		name = "Tab lines",
		p = { "<cmd>BufferPrevious<cr>", "previous tab" },
		n = { "<cmd>BufferNext<cr>", "next tab" },
		s = { "<cmd>BufferPick<cr>", "select tab" },
		c = { "<cmd>BufferClose<cr>", "close tab" },
	},
	c = {
		name = "Common Tools",
		f = { ":lua vim.lsp.buf.format()<cr>", "format current buf" },
		r = { "<cmd>ProjectRoot<cr>", "Go to project root" },
		h = { "<cmd>noh<cr>", "Clear search highlight" },
	},
	s = {
		name = "Search",
		f = { "<cmd>Telescope find_files<cr>", "Search file by name" },
		g = { "<cmd>Telescope live_grep<cr>", "Search with ripgrep" },
		b = { "<cmd>Telescope builtin.buffers<cr>", "Search current bufferj" },
		h = { "<cmd>Telescope help_tags<cr>", "Search help tags" },
		p = { "<cmd>Telescope projects<cr>", "Search projects" },
		B = { "<cmd>Telescope file_browser", "Open file explorer" },
		c = { "<cmd>Telescope colorscheme", "Search colorscheme" }
	},
}, { prefix = "<leader>" })

local leap = require('leap')
leap.add_default_mappings()
