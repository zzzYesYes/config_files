return {
  "nickjvandyke/opencode.nvim",
  branch = "main",
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}

    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("opencode").ask("@this: ")
    end, { desc = "Ask OpenCode…" })

    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      require("opencode").select()
    end, { desc = "Select OpenCode…" })

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
        vim.cmd("vsplit | terminal opencode")
        opencode_term_buf = vim.api.nvim_get_current_buf()
      end
    end
    vim.keymap.set("n", "<leader>ot", toggle_opencode, { desc = "Toggle OpenCode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this")
    end, { desc = "Send range to OpenCode", expr = true })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this") .. "_"
    end, { desc = "Send line to OpenCode", expr = true })

    require("which-key").add({
      { "<leader>o", group = "OpenCode" },
      { "<C-a>", desc = "Ask OpenCode…", mode = { "n", "x" } },
      { "<C-x>", desc = "Select OpenCode…", mode = { "n", "x" } },
      { "<leader>ot", desc = "Toggle OpenCode" },
      { "go", desc = "Send range to OpenCode", mode = { "n", "x" } },
      { "goo", desc = "Send line to OpenCode" },
    })
  end,
}
