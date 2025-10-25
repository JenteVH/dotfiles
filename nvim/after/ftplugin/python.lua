-- Python filetype plugin
-- This runs after filetype is detected

-- Enable pyright LSP for this buffer
if vim.lsp.config.pyright then
  vim.lsp.enable("pyright", { bufnr = 0 })
end
