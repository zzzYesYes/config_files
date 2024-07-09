local wk = require("which-key")

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
}, { prefix = "<leader>" })
