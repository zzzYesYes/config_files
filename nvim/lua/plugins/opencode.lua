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

    local function visible_terminal_window()
      if not opencode_term_buf or not vim.api.nvim_buf_is_valid(opencode_term_buf) then
        return nil
      end

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == opencode_term_buf then
          return win
        end
      end
    end

    local function show_terminal(open_window)
      local existing_win = visible_terminal_window()
      if existing_win then
        vim.api.nvim_win_close(existing_win, true)
        return
      end

      local buffer = opencode_term_buf
      local is_new = not buffer or not vim.api.nvim_buf_is_valid(buffer)
      if is_new then
        buffer = vim.api.nvim_create_buf(false, true)
        opencode_term_buf = buffer
      end

      local win = open_window(buffer)
      if is_new then
        vim.api.nvim_win_call(win, function()
          vim.fn.jobstart({ "opencode" }, { term = true })
        end)
      end
    end

    local function toggle_split()
      show_terminal(function(buffer)
        vim.cmd("botright vsplit")
        vim.api.nvim_win_set_buf(0, buffer)
        return vim.api.nvim_get_current_win()
      end)
    end

    local function toggle_float()
      show_terminal(function(buffer)
        local width = math.max(1, math.floor(vim.o.columns * 0.8))
        local height = math.max(1, math.floor(vim.o.lines * 0.8))
        return vim.api.nvim_open_win(buffer, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
          col = math.max(0, math.floor((vim.o.columns - width) / 2)),
          border = "rounded",
          title = " OpenCode ",
          title_pos = "center",
          style = "minimal",
        })
      end)
    end

    vim.keymap.set("n", "<leader>ot", toggle_split, { desc = "Toggle OpenCode split" })
    vim.keymap.set("n", "<leader>of", toggle_float, { desc = "Toggle OpenCode float" })

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
      { "<leader>of", desc = "Toggle OpenCode float" },
      { "<leader>ot", desc = "Toggle OpenCode split" },
      { "go", desc = "Send range to OpenCode", mode = { "n", "x" } },
      { "goo", desc = "Send line to OpenCode" },
    })
  end,
}
