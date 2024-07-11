return {
  "akinsho/bufferline.nvim",
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
  event = "BufWinEnter",
  opts = {
    options = {
      indicator = {
        style = "underline",
      },
      offsets = {
	filetype = "neo-tree",
      },
    }
  },
}
