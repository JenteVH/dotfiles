return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = "<leader>r",
    kulala_keymaps = {
      ["Previous tab"] = false,
      ["Next tab"] = false,
    },
    ui = {
      max_response_size = 5242880,
    },
  },
}
