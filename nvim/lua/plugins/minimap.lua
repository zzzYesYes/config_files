return {
  "wfxr/minimap.vim",
  build = "cargo install --locked code-minimap",
  opts = {},
  config = function()
    vim.g.minimap_width = 20
    vim.g.minimap_highlight_serach = 1
  end,
}
