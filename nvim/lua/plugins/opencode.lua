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
    -- Plugin has no built-in toggle; show/hide an `opencode --port` terminal ourselves
    local opencode_term_buf
    local function toggle_opencode()
      if opencode_term_buf and vim.api.nvim_buf_is_valid(opencode_term_buf) then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == opencode_term_buf then
            vim.api.nvim_win_close(win, true)
            return
          end
        end
        vim.cmd("vsplit | buffer " .. opencode_term_buf)
      else
        vim.cmd("vsplit | terminal opencode --port")
        opencode_term_buf = vim.api.nvim_get_current_buf()
      end
    end
    vim.keymap.set({ "n" }, "<leader>ot", toggle_opencode, { desc = "Toggle opencode" })

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
