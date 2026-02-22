return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        configure = true,
        config = {
          gui = { nerdFontsVersion = "3" },
        },
      },
    },
    keys = {
      { "<leader>gg", function() Snacks.lazygit() end, desc = "LazyGit" },
      { "<leader>gl", function() Snacks.lazygit.log() end, desc = "LazyGit log" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "LazyGit file log" },
    },
  },
}
