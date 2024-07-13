local wk = require("which-key")
require("telescope.builtin")
require("telescope").load_extension("projects")
-- Suggested Spec:
wk.add({
    { "<leader>S",  group = "Session" },
    { "<leader>SQ", "<cmd>lua require('persistence').stop()<cr>",                desc = "Quit without saving session" },
    { "<leader>Sc", "<cmd>lua require('persistence').load()<cr>",                desc = "Restore last session for current dir" },
    { "<leader>Sl", "<cmd>lua require('persistence').load({ last = true })<cr>", desc = "Restore last session" },
    { "<leader>T",  group = "Uncommon Tools" },
    { "<leader>Tl", "<cmd>Lazy<cr>",                                             desc = "Lazy Nvim" },
    { "<leader>Tm", "<cmd>Mason<cr>",                                            desc = "Mason" },
    { "<leader>b",  group = "Bottom Panel" },
    { "<leader>bt", "<cmd>TodoQuickFix<cr>",                                     desc = "Toggle todo list" },
    { "<leader>c",  group = "Common Tools" },
    { "<leader>cf", ":lua vim.lsp.buf.format()<cr>",                             desc = "format current buf" },
    { "<leader>ch", "<cmd>noh<cr>",                                              desc = "Clear search highlight" },
    { "<leader>cr", "<cmd>ProjectRoot<cr>",                                      desc = "Go to project root" },
    { "<leader>l",  group = "Left Panel" },
    { "<leader>le", "<cmd>Neotree toggle<cr>",                                   desc = "File Explorer" },
    { "<leader>r",  group = "Right Panel" },
    { "<leader>rm", "<cmd>MinimapToggle<cr>",                                    desc = "Minimap" },
    { "<leader>rs", "<cmd>SymbolsOutline<cr>",                                   desc = "Symbols Outline" },
    { "<leader>s",  group = "Search" },
    { "<leader>sB", "<cmd>Telescope file_browser",                               desc = "Open file explorer" },
    { "<leader>sb", "<cmd>Telescope builtin.buffers<cr>",                        desc = "Search current bufferj" },
    { "<leader>sc", "<cmd>Telescope colorscheme",                                desc = "Search colorscheme" },
    { "<leader>sf", "<cmd>Telescope find_files<cr>",                             desc = "Search file by name" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>",                              desc = "Search with ripgrep" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>",                              desc = "Search help tags" },
    { "<leader>sp", "<cmd>Telescope projects<cr>",                               desc = "Search projects" },
    { "<leader>t",  group = "Tab lines" },
    { "<leader>tc", "<cmd>BufferClose<cr>",                                      desc = "close tab" },
    { "<leader>tn", "<cmd>BufferNext<cr>",                                       desc = "next tab" },
    { "<leader>tp", "<cmd>BufferPrevious<cr>",                                   desc = "previous tab" },
    { "<leader>ts", "<cmd>BufferPick<cr>",                                       desc = "select tab" },
})

local leap = require('leap')
leap.add_default_mappings()
