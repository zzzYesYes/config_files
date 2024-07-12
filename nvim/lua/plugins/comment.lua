return {
  "numToStr/Comment.nvim",
  event = "BufRead",
  init = function ()
  	require("Comment").setup()
  end,
}
