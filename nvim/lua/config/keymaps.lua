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
    { "<leader>bd", "<cmd>TodoQuickFix<cr>",                                     desc = "Toggle todo list" },
    { "<leader>bt", "<cmd>ToggleTerm direction=horizontal<cr>",                  desc = "Toggle terminal" },
    { "<leader>c",  group = "Common Tools" },
    { "<leader>cf", ":lua vim.lsp.buf.format()<cr>",                             desc = "format current buf" },
    { "<leader>ch", "<cmd>noh<cr>",                                              desc = "Clear search highlight" },
    { "<leader>cr", "<cmd>ProjectRoot<cr>",                                      desc = "Go to project root" },
    { "<leader>l",  group = "Left Panel" },
    { "<leader>le", "<cmd>Neotree toggle<cr>",                                   desc = "File Explorer" },
    { "<leader>r",  group = "Right Panel" },
    { "<leader>rm", "<cmd>MinimapToggle<cr>",                                    desc = "Minimap" },
    { "<leader>rs", "<cmd>SymbolsOutline<cr>",                                   desc = "Symbols Outline" },
    { "<leader>rt", "<cmd>ToggleTerm direction=vertical<cr>",                    desc = "Vertical Terminal" },
    { "<leader>s",  group = "Search" },
    { "<leader>sB", "<cmd>Telescope file_browser",                               desc = "Open file explorer" },
    { "<leader>sb", "<cmd>Telescope builtin.buffers<cr>",                        desc = "Search current bufferj" },
    { "<leader>sc", "<cmd>Telescope colorscheme<cr>",                            desc = "Search colorscheme" },
    { "<leader>sf", "<cmd>Telescope find_files<cr>",                             desc = "Search file by name" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>",                              desc = "Search with ripgrep" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>",                              desc = "Search help tags" },
    { "<leader>sp", "<cmd>Telescope projects<cr>",                               desc = "Search projects" },
    { "<leader>t",  group = "Tab lines" },
    { "<leader>tc", "<cmd>BufferClose<cr>",                                      desc = "close tab" },
    { "<leader>tn", "<cmd>BufferNext<cr>",                                       desc = "next tab" },
    { "<leader>tp", "<cmd>BufferPrevious<cr>",                                   desc = "previous tab" },
    { "<leader>ts", "<cmd>BufferPick<cr>",                                       desc = "select tab" },
    { "<leader>q", "<cmd>q!<cr>",                                                desc = "quit" },
    { "<leader>w", "<cmd>w!<cr>",                                                desc = "write" },
    { "<leader>x", "<cmd>x!<cr>",                                                desc = "write and quit" },
})

-- Mappings
vim.keymap.set({ "n" }, "<C-h>", [[<cmd>wincmd h<cr>]])
vim.keymap.set({ "n" }, "<C-j>", [[<cmd>wincmd j<cr>]])
vim.keymap.set({ "n" }, "<C-k>", [[<cmd>wincmd k<cr>]])
vim.keymap.set({ "n" }, "<C-l>", [[<cmd>wincmd l<cr>]])

vim.keymap.set({"n"}, [[<C-\>]], [[<cmd>ToggleTerm<cr>]])

function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local leap = require('leap')
leap.add_default_mappings()
