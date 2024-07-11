require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "tsserver",
    "rust_analyzer",
  },
})
local lspconfig = require("lspconfig")
local on_attach = function(client, bufnr)
	local buf_set_option = vim.api.nvim_buf_set_option
	buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

require("mason-lspconfig").setup_handlers({
  function(servername)
    lspconfig[servername].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,
})
