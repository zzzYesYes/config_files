return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    cmd = "ToggleTerm",
    opts = {
      size = function(term)
	if term.direction == "horizontal" then
	  return 15
	elseif term.direction == "vertical" then
	  return vim.o.columns * 0.4
	end
      end,
      open_mapping = [[<C-\>]],
      hid_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = "float" or "horizontal" or "vertical" or "window",
      float_opts = {
          border = "single",
      },
      close_on_exit = true,
    },
  },
}
