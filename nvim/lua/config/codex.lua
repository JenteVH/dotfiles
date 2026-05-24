local M = {}

local state = {
  buf = nil,
  win = nil,
  job = nil,
  chan = nil,
  root = nil,
  layout = "vertical",
}

local config = {
  cmd = "codex",
  width = 0.35,
  height = 0.35,
  markers = { ".git", "package.json", "go.mod", "Cargo.toml", "pyproject.toml", "mix.exs" },
  keymaps = true,
}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Codex" })
end

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function buf_dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    return vim.fn.fnamemodify(name, ":p:h")
  end
  return vim.loop.cwd()
end

local function project_root()
  local start = buf_dir()

  if vim.fs and vim.fs.find and vim.fs.dirname then
    local found = vim.fs.find(config.markers, { path = start, upward = true })[1]
    if found then
      return vim.fs.dirname(found)
    end
  end

  return vim.loop.cwd()
end

local function relpath(path)
  local root = state.root or project_root()
  local normalized = vim.fs and vim.fs.normalize and vim.fs.normalize(path) or path
  local normalized_root = vim.fs and vim.fs.normalize and vim.fs.normalize(root) or root

  if normalized:sub(1, #normalized_root + 1) == normalized_root .. "/" then
    return normalized:sub(#normalized_root + 2)
  end

  return normalized
end

local function current_file()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    notify("Current buffer has no file path", vim.log.levels.WARN)
    return nil
  end
  return path
end

local function current_filetype()
  local ft = vim.bo.filetype
  if ft == "" then
    return ""
  end
  return ft
end

local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "codex"
  return buf
end

local function set_terminal_keymaps(buf)
  vim.keymap.set("t", "<C-q>", function()
    M.close()
  end, { buffer = buf, desc = "Hide Codex" })

  vim.keymap.set("n", "<C-q>", function()
    M.close()
  end, { buffer = buf, desc = "Hide Codex" })
end

local function open_window(focus)
  if is_valid_win(state.win) then
    if focus then
      vim.api.nvim_set_current_win(state.win)
      vim.cmd("startinsert")
    end
    return
  end

  if not is_valid_buf(state.buf) then
    state.buf = create_buffer()
    set_terminal_keymaps(state.buf)
  end

  local previous_win = vim.api.nvim_get_current_win()

  if state.layout == "horizontal" then
    vim.cmd("botright split")
    state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_height(state.win, math.max(8, math.floor(vim.o.lines * config.height)))
  else
    vim.cmd("botright vertical split")
    state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(state.win, math.max(30, math.floor(vim.o.columns * config.width)))
  end

  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = "no"

  if focus then
    vim.api.nvim_set_current_win(state.win)
    vim.cmd("startinsert")
  elseif vim.api.nvim_win_is_valid(previous_win) then
    vim.api.nvim_set_current_win(previous_win)
  end
end

local function ensure_job()
  if state.job and state.chan then
    return true
  end

  if vim.fn.executable(config.cmd) == 0 then
    notify("Codex CLI not found on PATH: " .. config.cmd, vim.log.levels.ERROR)
    return false
  end

  if not is_valid_buf(state.buf) then
    state.buf = create_buffer()
    set_terminal_keymaps(state.buf)
  end

  state.root = project_root()

  local function start_terminal()
    state.job = vim.fn.termopen({ config.cmd, "--cd", state.root }, {
      cwd = state.root,
      on_exit = function(_, code)
        state.job = nil
        state.chan = nil
        if code ~= 0 then
          vim.schedule(function()
            notify("Codex exited with code " .. tostring(code), vim.log.levels.WARN)
          end)
        end
      end,
    })
  end

  if is_valid_win(state.win) then
    vim.api.nvim_win_call(state.win, start_terminal)
  else
    local previous_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_set_current_buf(state.buf)
    start_terminal()
    if is_valid_buf(previous_buf) then
      vim.api.nvim_set_current_buf(previous_buf)
    end
  end

  state.chan = state.job
  vim.bo[state.buf].filetype = "codex"

  return state.job and state.job > 0
end

local function ensure_open(focus)
  open_window(focus)
  return ensure_job()
end

local function paste(text, submit, focus)
  if not ensure_open(focus ~= false) then
    return
  end

  text = text:gsub("\r\n", "\n"):gsub("\r", "\n")

  vim.defer_fn(function()
    if not state.chan then
      notify("Codex terminal is not running", vim.log.levels.WARN)
      return
    end

    vim.fn.chansend(state.chan, "\27[200~" .. text .. "\27[201~")
    if submit then
      vim.defer_fn(function()
        if state.chan then
          vim.fn.chansend(state.chan, "\r")
        end
      end, 20)
    end
  end, 40)
end

local function code_context(text, source, line1, line2)
  local location = source
  if line1 and line2 then
    if line1 == line2 then
      location = string.format("%s:%d", source, line1)
    else
      location = string.format("%s:%d-%d", source, line1, line2)
    end
  end

  return table.concat({
    "Context from " .. location .. ":",
    "",
    "```" .. current_filetype(),
    text,
    "```",
  }, "\n")
end

local function get_lines(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  return table.concat(lines, "\n")
end

local function visual_range()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local line1 = start_pos[2]
  local line2 = end_pos[2]

  if line1 > line2 then
    line1, line2 = line2, line1
  end

  return line1, line2
end

local function ask_with_context(context)
  vim.ui.input({ prompt = "Codex: " }, function(input)
    if not input or input == "" then
      return
    end

    if context and context ~= "" then
      paste(context .. "\n\n" .. input, true, true)
    else
      paste(input, true, true)
    end
  end)
end

function M.open()
  ensure_open(true)
end

function M.close()
  if is_valid_win(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.toggle()
  if is_valid_win(state.win) then
    M.close()
  else
    M.open()
  end
end

function M.toggle_layout()
  state.layout = state.layout == "vertical" and "horizontal" or "vertical"

  if is_valid_win(state.win) then
    M.close()
    M.open()
  end
end

function M.ask(prompt)
  if prompt and prompt ~= "" then
    paste(prompt, true, true)
    return
  end

  ask_with_context(nil)
end

function M.ask_about_buffer()
  local path = current_file()
  if not path then
    return
  end

  local context = "Use this file as context: " .. relpath(path)
  if vim.bo.modified then
    context = context .. "\nNote: this buffer has unsaved changes in Neovim."
  end

  ask_with_context(context)
end

function M.reference_buffer()
  local path = current_file()
  if not path then
    return
  end

  local text = "Use this file as context: " .. relpath(path)
  if vim.bo.modified then
    text = text .. "\nNote: this buffer has unsaved changes in Neovim."
  end

  paste(text, false, true)
end

function M.add_range(line1, line2, submit)
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and relpath(path) or "[No Name]"
  local text = get_lines(line1, line2)

  if text == "" then
    notify("No text to send", vim.log.levels.WARN)
    return
  end

  paste(code_context(text, path, line1, line2), submit == true, true)
end

function M.ask_about_range(line1, line2, prompt)
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and relpath(path) or "[No Name]"
  local text = get_lines(line1, line2)
  local context = code_context(text, path, line1, line2)

  if prompt and prompt ~= "" then
    paste(context .. "\n\n" .. prompt, true, true)
  else
    ask_with_context(context)
  end
end

function M.add_visual()
  local line1, line2 = visual_range()
  M.add_range(line1, line2, false)
end

function M.ask_about_visual()
  local line1, line2 = visual_range()
  M.ask_about_range(line1, line2)
end

function M.add_current_line()
  M.add_range(vim.fn.line("."), vim.fn.line("."), false)
end

function M.operator()
  _G.codex_operator = function()
    local start_pos = vim.api.nvim_buf_get_mark(0, "[")
    local end_pos = vim.api.nvim_buf_get_mark(0, "]")
    M.add_range(start_pos[1], end_pos[1], false)
  end

  vim.go.operatorfunc = "v:lua.codex_operator"
  return "g@"
end

local function create_commands()
  vim.api.nvim_create_user_command("Codex", function()
    M.toggle()
  end, { desc = "Toggle Codex" })

  vim.api.nvim_create_user_command("CodexToggle", function()
    M.toggle()
  end, { desc = "Toggle Codex" })

  vim.api.nvim_create_user_command("CodexOpen", function()
    M.open()
  end, { desc = "Open Codex" })

  vim.api.nvim_create_user_command("CodexClose", function()
    M.close()
  end, { desc = "Hide Codex" })

  vim.api.nvim_create_user_command("CodexAsk", function(opts)
    if opts.range > 0 then
      M.ask_about_range(opts.line1, opts.line2, opts.args)
    else
      M.ask(opts.args)
    end
  end, { nargs = "*", range = true, desc = "Ask Codex" })

  vim.api.nvim_create_user_command("CodexAdd", function(opts)
    if opts.range > 0 then
      M.add_range(opts.line1, opts.line2, false)
      return
    end

    if opts.args and opts.args ~= "" then
      paste("Use this file as context: " .. opts.args, false, true)
    else
      M.reference_buffer()
    end
  end, { nargs = "?", range = true, complete = "file", desc = "Add context to Codex" })
end

local function create_keymaps()
  vim.keymap.set({ "n", "t" }, "<leader>kt", function()
    M.toggle()
  end, { desc = "Toggle Codex" })

  vim.keymap.set({ "n", "t" }, "<leader>kf", function()
    M.open()
  end, { desc = "Focus Codex" })

  vim.keymap.set({ "n", "t" }, "<leader>kq", function()
    M.close()
  end, { desc = "Hide Codex" })

  vim.keymap.set("n", "<leader>ka", function()
    M.ask()
  end, { desc = "Ask Codex" })

  vim.keymap.set("x", "<leader>ka", function()
    M.ask_about_visual()
  end, { desc = "Ask Codex about selection" })

  vim.keymap.set("n", "<leader>kb", function()
    M.reference_buffer()
  end, { desc = "Add buffer to Codex" })

  vim.keymap.set("n", "<leader>kB", function()
    M.ask_about_buffer()
  end, { desc = "Ask Codex about buffer" })

  vim.keymap.set("n", "<leader>kl", function()
    M.add_current_line()
  end, { desc = "Add line to Codex" })

  vim.keymap.set("x", "<leader>ks", function()
    M.add_visual()
  end, { desc = "Add selection to Codex" })

  vim.keymap.set("n", "<leader>kp", function()
    M.toggle_layout()
  end, { desc = "Toggle Codex split direction" })

  vim.keymap.set("n", "gC", function()
    return M.operator()
  end, { desc = "Add range to Codex", expr = true })

  vim.keymap.set("x", "gC", function()
    M.add_visual()
  end, { desc = "Add selection to Codex" })

  vim.keymap.set("n", "gCC", function()
    return M.operator() .. "_"
  end, { desc = "Add line to Codex", expr = true })
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  create_commands()

  if config.keymaps then
    create_keymaps()
  end
end

return M
