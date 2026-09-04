return {
  {
    "DrKJeff16/project.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "Find project" },
    },
    config = function()
      require("project").setup({})
      pcall(require("telescope").load_extension, "projects")
    end,
  },
}
