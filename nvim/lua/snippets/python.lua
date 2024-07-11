local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.snippets.python = {
  s("def", {
    t("def "), i(1, "function_name"), t("("), i(2, "params"), t({"):", "\t"}),
    i(0),
  })
}

return {
  snippets = ls.snippets.python
}
