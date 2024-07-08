local wk = require("which-key")

wk.register({
  l = {
    name = "Left Panel",
    e = { "<cmd>Neotree toggle<cr>", "File Explorer" },
    b = { function() print("hello") end, "Test function" },
  }
}, { prefix = "<leader>" })
