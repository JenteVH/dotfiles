local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Python specific settings
autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = "88"
    vim.opt_local.textwidth = 88
    vim.opt_local.formatoptions:remove("t")
  end,
})

-- Auto format on save for Python files
autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    if vim.lsp.get_active_clients({ bufnr = 0 })[1] then
      vim.lsp.buf.format()
    end
  end,
})

-- Auto format on save for Go files
autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    if vim.lsp.get_active_clients({ bufnr = 0 })[1] then
      vim.lsp.buf.format()
    end
  end,
})

-- Set correct filetype for Python files
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.py", "*.pyw" },
  callback = function()
    vim.bo.filetype = "python"
  end,
})

