return {
  "JenteVH/ndo.vim",
  keys = {
    { "<leader>T", function() require("ndo").open_todo() end, desc = "Open TODO file" },
  },
  ft = "todo",
  config = function()
    require("ndo").setup({})
  end,
}
