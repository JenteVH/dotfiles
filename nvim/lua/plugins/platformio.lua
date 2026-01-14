return {
  "anurag3301/nvim-platformio.lua",
  cond = function()
    local platformioRootDir = (vim.fn.filereadable("platformio.ini") == 1) and vim.fn.getcwd() or nil
    if platformioRootDir then
      vim.g.platformioRootDir = platformioRootDir
    end
    return vim.g.platformioRootDir ~= nil
  end,
  dependencies = {
    { "akinsho/toggleterm.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "folke/which-key.nvim" },
    { "nvim-treesitter/nvim-treesitter" },
  },
  config = function()
    -- Optional: Configure PlatformIO settings
    vim.g.pioConfig = {
      lsp = "clangd",          -- options: clangd | ccls
      clangd_source = "ccls",  -- options: ccls | compiledb
      menu_key = "<leader>p",  -- menu keybinding
      debug = false,           -- enable debug messages
    }
  end,
}
