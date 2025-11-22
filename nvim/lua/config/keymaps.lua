local keymap = vim.keymap.set

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Navigate left" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Navigate down" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Navigate up" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Navigate right" })

-- Fix for terminals that send backspace for C-h
keymap("n", "<BS>", "<C-w>h", { desc = "Navigate left (backspace fix)" })

-- Window splits
keymap("n", "<leader>wv", ":vsplit<CR>", { desc = "Split vertically" })
keymap("n", "<leader>wh", ":split<CR>", { desc = "Split horizontally" })
keymap("n", "<leader>wx", ":close<CR>", { desc = "Close split" })
keymap("n", "<leader>we", "<C-w>=", { desc = "Make splits equal" })

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

-- Quick quit
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all without saving" })

-- Format is handled by LSP config (lua/plugins/lsp.lua)

-- Copy file path
keymap("n", "<leader>yp", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end, { desc = "Copy full path" })
keymap("n", "<leader>yr", function() vim.fn.setreg("+", vim.fn.expand("%")) end, { desc = "Copy relative path" })

-- Buffer management
keymap("n", "<leader>c", ":bdelete<CR>", { desc = "Close buffer" })
keymap("n", "<leader>C", ":bdelete!<CR>", { desc = "Force close buffer" })

-- Save file
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>W", ":wa<CR>", { desc = "Save all files" })

-- Git blame (changed from gb to gB to avoid conflict with git branches)
keymap("n", "<leader>gB", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle git blame" })

-- Terminal mode mappings
keymap("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Debug helper - show current window number
keymap("n", "<leader>?", function()
  vim.notify("Window " .. vim.fn.winnr() .. " of " .. vim.fn.winnr('$'), vim.log.levels.INFO)
end, { desc = "Show window number" })
