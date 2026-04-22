-- JSON filetype plugin
-- This runs after filetype is detected

-- Set JSON-specific options (2-space indent is the standard convention)
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
