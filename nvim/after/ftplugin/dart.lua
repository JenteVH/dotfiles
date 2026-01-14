vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

-- Disable treesitter indent for Dart (it's buggy)
vim.bo.indentexpr = ""

-- Use cindent which works well for C-style syntax like Dart
vim.bo.cindent = true
