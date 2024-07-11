local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.snippets.lua = {
  s({
      trig = "fn",
      name = "Function",
      docstring = "Create a lua function",
    },
    {
      t("function "), i(1, "name"), t("("), i(2, "params"), t({")", "  "}),
      i(0),
      t({"", "end"}),
    }
  ),

  s("if", {
    t("if "), i(1, "condition"), t(" then"),
    t({"\t", ""}),
    t("end"),
    i(0),
  })
}

return {
  snippets = ls.snippets.lua
}

