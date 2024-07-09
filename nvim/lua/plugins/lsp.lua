return {
  {
    "williamboman/mason.nvim",
    init = function()
      require("mason").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    init = function()
      require("mason-lspconfig").setup({})
    end,
  },
}
