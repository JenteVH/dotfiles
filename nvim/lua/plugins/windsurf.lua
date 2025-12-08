return {
  {
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        enable_chat = true,
        virtual_text = {
          enabled = true,
          manual = false,
          idle_delay = 75,
          virtual_text_priority = 65535,
          map_keys = true,
          key_bindings = {
            accept = "<M-o>",
            accept_word = false,
            accept_line = false,
            clear = false,
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
      })
    end,
  },
}
