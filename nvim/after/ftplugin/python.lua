-- Python filetype plugin
-- This runs after filetype is detected

-- Set Python-specific options
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- Set the Python interpreter path for the container
vim.g.python3_host_prog = '/usr/local/bin/python3'
