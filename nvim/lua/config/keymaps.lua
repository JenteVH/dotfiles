local keymap = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better window navigation
keymap({ "n", "x" }, "<C-h>", "<Esc><C-w>h", { desc = "Navigate left" })
keymap({ "n", "x" }, "<C-j>", "<Esc><C-w>j", { desc = "Navigate down" })
keymap({ "n", "x" }, "<C-k>", "<Esc><C-w>k", { desc = "Navigate up" })
keymap({ "n", "x" }, "<C-l>", "<Esc><C-w>l", { desc = "Navigate right" })

-- Fix for terminals that send backspace for C-h
keymap("n", "<BS>", "<C-w>h", { desc = "Navigate left (backspace fix)" })

-- Window splits
keymap("n", "<leader>wv", ":vsplit<CR>", { desc = "Split vertically" })
keymap("n", "<leader>wh", ":split<CR>", { desc = "Split horizontally" })
keymap("n", "<leader>wx", ":close<CR>", { desc = "Close split" })
keymap("n", "<leader>we", "<C-w>=", { desc = "Make splits equal" })
keymap("n", "<leader>wr", "<cmd>wincmd R<CR>", { desc = "Rotate splits" })

-- Tab management
keymap("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "New tab" })
keymap("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })
for i = 1, 9 do
  keymap("n", "<leader>t" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- Resize splits with Alt/Option + arrows (better for macOS)
keymap("n", "<M-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<M-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Alternative: resize with leader + hjkl
keymap("n", "<leader>wK", ":resize +5<CR>", { desc = "Increase height" })
keymap("n", "<leader>wJ", ":resize -5<CR>", { desc = "Decrease height" })
keymap("n", "<leader>wL", ":vertical resize +5<CR>", { desc = "Increase width" })
keymap("n", "<leader>wH", ":vertical resize -5<CR>", { desc = "Decrease width" })

-- Move text up and down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Stay in indent mode
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Better paste
keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Wrap selected text
local function wrap_selection(left, right)
  local visual_mode = vim.api.nvim_get_mode().mode
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3] - 1

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  vim.cmd("normal! \27")

  if visual_mode == "V" then
    start_col = 0
    end_col = #(vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1] or "")
  elseif visual_mode == "\22" then
    for row = end_row, start_row, -1 do
      local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
      local row_start_col = math.min(start_col, #line)
      local row_end_col = math.min(end_col + 1, #line)
      local selected = vim.api.nvim_buf_get_text(0, row, row_start_col, row, row_end_col, {})
      selected[1] = left .. selected[1] .. right
      vim.api.nvim_buf_set_text(0, row, row_start_col, row, row_end_col, selected)
    end
    return
  else
    local end_line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1] or ""
    end_col = math.min(end_col + 1, #end_line)
  end

  local selected = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
  selected[1] = left .. selected[1]
  selected[#selected] = selected[#selected] .. right
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, selected)
end

local wrappers = {
  { '<leader>s"', '"', '"', "double quotes" },
  { "<leader>s'", "'", "'", "single quotes" },
  { "<leader>s`", "`", "`", "backticks" },
  { "<leader>s{", "{", "}", "curly braces" },
  { "<leader>s[", "[", "]", "square brackets" },
  { "<leader>s(", "(", ")", "parentheses" },
  { "<leader>s<lt>", "<", ">", "angle brackets" },
}

for _, wrapper in ipairs(wrappers) do
  keymap("x", wrapper[1], function()
    wrap_selection(wrapper[2], wrapper[3])
  end, { desc = "Wrap selection in " .. wrapper[4] })
end

-- Quick quit
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all without saving" })

-- Format buffer: LSP first, then filetype-specific fallback
keymap("n", "<leader>f", function()
  local clients = vim.lsp.get_clients({ bufnr = 0, dynamic_registration = false })
  local formatters = vim.iter(clients):filter(function(c)
    return c.supports_method("textDocument/formatting")
  end):totable()

  if #formatters > 0 then
    vim.lsp.buf.format({ async = true })
    return
  end

  local ft = vim.bo.filetype
  if ft == "json" then
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local result = vim.fn.system("python3 -m json.tool", lines)
    if vim.v.shell_error == 0 then
      local formatted = vim.split(result, "\n", { trimempty = true })
      vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
    end
  else
    vim.notify("No formatter available for " .. ft, vim.log.levels.WARN)
  end
end, { desc = "Format document" })

-- Copy file path
keymap("n", "<leader>yp", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Copy full path" })
keymap("n", "<leader>yr", function() vim.fn.setreg("+", vim.fn.expand("%")) end, { desc = "Copy relative path" })

-- Buffer management
keymap("n", "<leader>c", function() Snacks.bufdelete() end, { desc = "Close buffer" })
keymap("n", "<leader>C", function() Snacks.bufdelete({ force = true }) end, { desc = "Force close buffer" })
keymap("n", "<leader>cbo", ":BufferLineCloseOthers<CR>", { desc = "Close other buffers" })

-- Save file
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>W", ":wa<CR>", { desc = "Save all files" })

-- Folding keymaps (basic ones work without ufo)
-- za, zc, zo work out of the box
-- zK for peeking fold content (requires nvim-ufo)
keymap("n", "zK", function()
  local has_ufo, ufo = pcall(require, "ufo")
  if has_ufo then
    local winid = ufo.peekFoldedLinesUnderCursor()
    if not winid then
      vim.lsp.buf.hover()
    end
  else
    vim.lsp.buf.hover()
  end
end, { desc = "Peek fold or hover" })

-- Git blame (changed from gb to gB to avoid conflict with git branches)
keymap("n", "<leader>gB", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })

-- Terminal mode mappings
keymap("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
keymap("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Navigate left" })
keymap("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Navigate down" })
keymap("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Navigate up" })
keymap("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Navigate right" })

-- Scroll viewport without moving cursor (Alt + hjkl) - 10% of visible page
local function scroll_percent(direction)
  local lines = math.max(1, math.floor(vim.fn.winheight(0) * 0.1))
  local cols = math.max(1, math.floor(vim.fn.winwidth(0) * 0.1))
  local keys
  if direction == "down" then
    keys = vim.api.nvim_replace_termcodes(lines .. "<C-e>", true, false, true)
  elseif direction == "up" then
    keys = vim.api.nvim_replace_termcodes(lines .. "<C-y>", true, false, true)
  elseif direction == "left" then
    keys = cols .. "zh"
  elseif direction == "right" then
    keys = cols .. "zl"
  end
  vim.api.nvim_feedkeys(keys, "n", false)
end
keymap("n", "<M-j>", function() scroll_percent("down") end, { desc = "Scroll down 10%" })
keymap("n", "<M-k>", function() scroll_percent("up") end, { desc = "Scroll up 10%" })
keymap("n", "<M-h>", function() scroll_percent("left") end, { desc = "Scroll left 10%" })
keymap("n", "<M-l>", function() scroll_percent("right") end, { desc = "Scroll right 10%" })

-- Keep Ctrl-Shift fallbacks for terminals that do not pass Alt cleanly.
keymap("n", "<C-S-j>", function() scroll_percent("down") end, { desc = "Scroll down 10%" })
keymap("n", "<C-S-k>", function() scroll_percent("up") end, { desc = "Scroll up 10%" })
keymap("n", "<C-S-h>", function() scroll_percent("left") end, { desc = "Scroll left 10%" })
keymap("n", "<C-S-l>", function() scroll_percent("right") end, { desc = "Scroll right 10%" })

-- Debug helper - show current window number
keymap("n", "<leader>?", function()
  vim.notify("Window " .. vim.fn.winnr() .. " of " .. vim.fn.winnr('$'), vim.log.levels.INFO)
end, { desc = "Show window number" })
