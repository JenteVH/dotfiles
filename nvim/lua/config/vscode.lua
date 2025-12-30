-- VSCode Neovim configuration
-- Similar keybinds to regular nvim config, adapted for VSCode

local keymap = vim.keymap.set
local vscode = require("vscode")

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper function for VSCode commands
local function call(cmd)
  return function()
    vscode.call(cmd)
  end
end

-- Window navigation (using VSCode's workbench commands)
keymap("n", "<C-h>", call("workbench.action.navigateLeft"), { desc = "Navigate left" })
keymap("n", "<C-j>", call("workbench.action.navigateDown"), { desc = "Navigate down" })
keymap("n", "<C-k>", call("workbench.action.navigateUp"), { desc = "Navigate up" })
keymap("n", "<C-l>", call("workbench.action.navigateRight"), { desc = "Navigate right" })

-- Window splits
keymap("n", "<leader>wv", call("workbench.action.splitEditorRight"), { desc = "Split vertically" })
keymap("n", "<leader>wh", call("workbench.action.splitEditorDown"), { desc = "Split horizontally" })
keymap("n", "<leader>wx", call("workbench.action.closeActiveEditor"), { desc = "Close split" })
keymap("n", "<leader>we", call("workbench.action.evenEditorWidths"), { desc = "Make splits equal" })

-- Move text up and down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Stay in indent mode
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Better paste
keymap("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Buffer/Editor management
keymap("n", "<leader>c", call("workbench.action.closeActiveEditor"), { desc = "Close buffer" })
keymap("n", "<leader>C", call("workbench.action.closeActiveEditor"), { desc = "Force close buffer" })

-- Save file
keymap("n", "<leader>w", call("workbench.action.files.save"), { desc = "Save file" })
keymap("n", "<leader>W", call("workbench.action.files.saveAll"), { desc = "Save all files" })

-- Quick quit
keymap("n", "<leader>Q", call("workbench.action.closeWindow"), { desc = "Quit window" })

-- File navigation (Telescope equivalents)
keymap("n", "<leader>ff", call("workbench.action.quickOpen"), { desc = "Find files" })
keymap("n", "<leader><leader>", call("workbench.action.quickOpen"), { desc = "Find files" })
keymap("n", "<leader>fg", call("workbench.action.findInFiles"), { desc = "Find in files (grep)" })
keymap("n", "<leader>fb", call("workbench.action.showAllEditors"), { desc = "Find buffers" })
keymap("n", "<leader>fr", call("workbench.action.openRecent"), { desc = "Recent files" })

-- File explorer
keymap("n", "<leader>e", call("workbench.view.explorer"), { desc = "Toggle file explorer" })
keymap("n", "<leader>o", call("workbench.files.action.focusFilesExplorer"), { desc = "Focus file explorer" })

-- LSP equivalents
keymap("n", "gd", call("editor.action.revealDefinition"), { desc = "Go to definition" })
keymap("n", "gr", call("editor.action.goToReferences"), { desc = "Go to references" })
keymap("n", "gI", call("editor.action.goToImplementation"), { desc = "Go to implementation" })
keymap("n", "K", call("editor.action.showHover"), { desc = "Hover" })
keymap("n", "<leader>ca", call("editor.action.quickFix"), { desc = "Code action" })
keymap("n", "<leader>rn", call("editor.action.rename"), { desc = "Rename" })
keymap("n", "<leader>f", call("editor.action.formatDocument"), { desc = "Format document" })
keymap("v", "<leader>f", call("editor.action.formatSelection"), { desc = "Format selection" })
keymap("n", "[d", call("editor.action.marker.prev"), { desc = "Previous diagnostic" })
keymap("n", "]d", call("editor.action.marker.next"), { desc = "Next diagnostic" })
keymap("n", "<leader>D", call("editor.action.goToTypeDefinition"), { desc = "Type definition" })

-- Git
keymap("n", "<leader>gs", call("workbench.view.scm"), { desc = "Git status" })
keymap("n", "<leader>gB", call("gitlens.toggleLineBlame"), { desc = "Toggle git blame" })
keymap("n", "]h", call("workbench.action.editor.nextChange"), { desc = "Next hunk" })
keymap("n", "[h", call("workbench.action.editor.previousChange"), { desc = "Previous hunk" })

-- Comments
keymap("n", "gcc", call("editor.action.commentLine"), { desc = "Comment line" })
keymap("v", "gc", call("editor.action.commentLine"), { desc = "Comment selection" })

-- Folding
keymap("n", "za", call("editor.toggleFold"), { desc = "Toggle fold" })
keymap("n", "zc", call("editor.fold"), { desc = "Close fold" })
keymap("n", "zo", call("editor.unfold"), { desc = "Open fold" })
keymap("n", "zM", call("editor.foldAll"), { desc = "Close all folds" })
keymap("n", "zR", call("editor.unfoldAll"), { desc = "Open all folds" })

-- Search
keymap("n", "<leader>fw", call("editor.action.addSelectionToNextFindMatch"), { desc = "Find current word" })

-- Terminal
keymap("n", "<leader>tt", call("workbench.action.terminal.toggleTerminal"), { desc = "Toggle terminal" })

-- Problems/Diagnostics
keymap("n", "<leader>q", call("workbench.actions.view.problems"), { desc = "Open problems" })

-- Symbols
keymap("n", "<leader>ds", call("workbench.action.gotoSymbol"), { desc = "Document symbols" })
keymap("n", "<leader>ws", call("workbench.action.showAllSymbols"), { desc = "Workspace symbols" })
