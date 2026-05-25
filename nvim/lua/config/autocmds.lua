local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local autosave_timer

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto save normal file buffers after insert-mode and normal-mode edits.
autocmd({ "InsertLeave", "TextChanged" }, {
  group = augroup("autosave_insert_leave", { clear = true }),
  callback = function()
    if autosave_timer then
      autosave_timer:stop()
    end

    autosave_timer = vim.defer_fn(function()
      if vim.bo.buftype == "" and vim.bo.modified and vim.bo.modifiable and not vim.bo.readonly and vim.api.nvim_buf_get_name(0) ~= "" then
        vim.cmd("silent write")
      end
    end, 300)
  end,
})

-- Python specific settings
autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = "88"
    vim.opt_local.textwidth = 88
    vim.opt_local.formatoptions:remove("t")
  end,
})

-- Auto format on save for Python files
autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.lsp.buf.format()
    end
  end,
})

-- Auto format on save for Go files
autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      vim.lsp.buf.format()
    end
  end,
})

-- Set correct filetype for Python files
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.py", "*.pyw" },
  callback = function()
    vim.bo.filetype = "python"
  end,
})

-- Detect JSON content in text files
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.txt",
  group = augroup("json_detect", { clear = true }),
  callback = function()
    local line = vim.fn.getline(1)
    if line:match("^%s*[%[%{]") then
      vim.bo.filetype = "json"
    end
  end,
})

-- Format JSON via python when jsonls isn't active
autocmd("BufWritePre", {
  pattern = "*.json",
  callback = function()
    if not vim.lsp.get_clients({ bufnr = 0, name = "jsonls" })[1] then
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local result = vim.fn.system("python3 -m json.tool", lines)
      if vim.v.shell_error == 0 then
        local formatted = vim.split(result, "\n", { trimempty = true })
        vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
      end
    end
  end,
})
