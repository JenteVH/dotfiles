local opt = vim.opt

-- Add local bin to PATH for custom scripts
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH

-- General options
opt.number = true
opt.relativenumber = true

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

-- Folding (configured by nvim-ufo plugin)
-- Basic settings, ufo will override these
opt.foldlevel = 99
opt.foldlevelstart = 99

-- Disable smartindent when Treesitter indent is available for the filetype
-- This prevents conflicts between the two indentation systems
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
    if ts_ok then
      local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
      local has_parser = pcall(vim.treesitter.language.inspect, lang)
      if has_parser and ts_configs.is_enabled("indent", lang) then
        vim.bo.smartindent = false
      end
    end
  end,
})
