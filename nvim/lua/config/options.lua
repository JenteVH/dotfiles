local opt = vim.opt

-- Add local bin to PATH for custom scripts
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH

-- General options
opt.number = true
opt.relativenumber = true
opt.clipboard = "unnamedplus"
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.wrap = false
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.expand("~/.vim/undodir")
opt.undofile = true
opt.hlsearch = false
opt.incsearch = true
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.updatetime = 50
opt.colorcolumn = "88"
opt.cursorline = true
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true
opt.completeopt = "menuone,noselect"
opt.pumheight = 10
opt.hidden = true  -- Allow hidden buffers (don't force save when switching)

-- Python specific
opt.pyxversion = 3

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99  -- Start with all folds open
opt.foldenable = true
