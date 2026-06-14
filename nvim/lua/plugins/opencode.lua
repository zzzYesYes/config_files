return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      lsp = { enabled = false },
    }

    vim.o.autoread = true -- Required for `opts.events.reload`

    -- Recommended/example keymaps
    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
    vim.keymap.set({ "n" }, "<leader>ot", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })


    local wk = require("which-key")
    wk.add({
      { "<leader>o",  group = "Opencode" },
      { "<C-a>", desc = "Ask opencode…", mode = { "n", "x" } },
      { "<C-x>", desc = "Execute opencode action…", mode = { "n", "x" } },
      { "<leader>ot", desc = "Toggle opencode" },
      { "go", desc = "Add range to opencode", mode = { "n", "x" } },
      { "goo", desc = "Add line to opencode" },
    })
  end,
}
