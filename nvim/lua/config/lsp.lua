local capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local function telescope(method)
      return function()
        require("telescope.builtin")[method]()
      end
    end

    local opts = { buffer = event.buf }
    vim.keymap.set("n", "grd", telescope("lsp_definitions"),
      vim.tbl_extend("force", opts, { desc = "LSP definitions" }))
    vim.keymap.set("n", "grr", telescope("lsp_references"),
      vim.tbl_extend("force", opts, { desc = "LSP references" }))
    vim.keymap.set("n", "gri", telescope("lsp_implementations"),
      vim.tbl_extend("force", opts, { desc = "LSP implementations" }))
    vim.keymap.set("n", "grt", telescope("lsp_type_definitions"),
      vim.tbl_extend("force", opts, { desc = "LSP type definitions" }))
    vim.keymap.set("n", "gO", telescope("lsp_document_symbols"),
      vim.tbl_extend("force", opts, { desc = "LSP document symbols" }))
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "/usr/share/hypr/stubs/",
          "${3rd}/luv/library",
        },
      },
    },
  },
})

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
})

require("mason").setup({
  PATH = "append",
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "clangd",
  },
})
