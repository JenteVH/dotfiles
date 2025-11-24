local opt = vim.opt

-- Add local bin to PATH for custom scripts
vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH

-- General options
opt.number = true
opt.relativenumber = true

-- OSC 52 clipboard support for Docker
local function copy_to_osc52(lines)
  local text = table.concat(lines, '\n')
  local b64 = vim.fn.system('base64 -w0', text)
  b64 = string.gsub(b64, '\n', '')
  local osc52 = string.format('\027]52;c;%s\007', b64)

  -- Try multiple methods to send OSC 52
  if vim.fn.exists('$TMUX') == 1 then
    -- Wrap in tmux passthrough if inside tmux
    osc52 = string.format('\027Ptmux;\027%s\027\\', osc52)
  end

  io.stdout:write(osc52)
  io.stdout:flush()
end

vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = function(lines)
      copy_to_osc52(lines)
    end,
    ['*'] = function(lines)
      copy_to_osc52(lines)
    end,
  },
  paste = {
    ['+'] = function() return {} end,
    ['*'] = function() return {} end,
  },
}
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
