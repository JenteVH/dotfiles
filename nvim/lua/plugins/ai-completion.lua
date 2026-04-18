return {
  {
    "monkoose/neocodeium",
    event = "VeryLazy",
    config = function()
      local neocodeium = require("neocodeium")
      neocodeium.setup({
        manual = false,
        show_label = true,
        debounce = false,
        filetypes = {
          help = false,
          gitcommit = false,
          gitrebase = false,
          ["."] = false,
        },
      })

      vim.keymap.set("i", "<M-o>", neocodeium.accept)
      vim.keymap.set("i", "<M-]>", function() neocodeium.cycle_or_complete(1) end)
      vim.keymap.set("i", "<M-[>", function() neocodeium.cycle_or_complete(-1) end)
    end,
  },
}
