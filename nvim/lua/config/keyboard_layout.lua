local M = {}

local active = false
local layout_mappings = {}
local lookup
local snapshots = {}
local buffer_snapshots = {}
local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "keyboard-layout")
local removed_global_mappings = {
  { mode = "x", lhs = "an" },
  { mode = "o", lhs = "an" },
  { mode = "x", lhs = "in" },
  { mode = "o", lhs = "in" },
}

local function map(modes, lhs, rhs, desc, opts)
  return {
    modes = modes,
    lhs = lhs,
    rhs = rhs,
    desc = desc,
    opts = opts or {},
  }
end

local function peek_fold()
  local ok, ufo = pcall(require, "ufo")
  if ok then
    local winid = ufo.peekFoldedLinesUnderCursor()
    if not winid then
      lookup()
    end
    return
  end

  lookup()
end

local function execute_original(keys)
  local count = ""
  if vim.v.count > 0 then
    count = tostring(vim.v.count)
  end
  local existing = vim.fn.maparg(keys, "n", false, true)
  if type(existing) == "table" and existing.buffer == 1 then
    local termcodes = vim.api.nvim_replace_termcodes(count .. keys, true, false, true)
    vim.api.nvim_feedkeys(termcodes, "m", false)
    return
  end

  vim.cmd("normal! " .. count .. keys)
end

local function normal_counted(key)
  return function()
    vim.cmd("normal! " .. vim.v.count1 .. key)
  end
end

local function select_node(outer)
  local count = vim.v.count1
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    local select = require("vim.treesitter._select")
    if outer then
      select.select_parent(count)
      return
    end
    select.select_child(count)
    return
  end

  if outer then
    vim.lsp.buf.selection_range(count)
    return
  end
  vim.lsp.buf.selection_range(-count)
end

local function build_mappings()
  return {
    map({ "n", "x", "o" }, "n", "h", "Colemak: move left"),
    map({ "n", "x", "o" }, "u", "k", "Colemak: move up"),
    map({ "n", "x", "o" }, "e", "j", "Colemak: move down"),
    map({ "n", "x", "o" }, "i", "l", "Colemak: move right"),
    map({ "n", "x" }, "j", "<C-u>", "Colemak: page up"),
    map({ "n", "x" }, "h", "<C-d>", "Colemak: page down"),
    map({ "n", "x", "o" }, "L", "^", "Colemak: first non-blank"),
    map({ "n", "x", "o" }, "Y", "$", "Colemak: end of line"),
    map({ "n", "x", "o" }, "l", "b", "Colemak: previous word"),
    map({ "n", "x", "o" }, "y", "w", "Colemak: next word"),
    map({ "n", "x", "o" }, "<C-l>", "B", "Colemak: previous WORD"),
    map({ "n", "x", "o" }, "<C-y>", "W", "Colemak: next WORD"),
    map("n", "N", ":BufferLineCyclePrev<CR>", "Colemak: previous buffer"),
    map("n", "I", ":BufferLineCycleNext<CR>", "Colemak: next buffer"),
    map({ "n", "x", "o" }, "gN", "gE", "Colemak: previous WORD end"),
    map({ "n", "x", "o" }, "gI", "E", "Colemak: next WORD end"),
    map("n", "(", "<C-o>", "Colemak: jump back"),
    map("n", ")", "<C-i>", "Colemak: jump forward"),
    map("n", "g(", "(", "Colemak: previous sentence"),
    map("n", "g)", ")", "Colemak: next sentence"),
    map({ "x", "o" }, "r", "i", "Colemak: inner text object"),
    map({ "x", "o" }, "t", "a", "Colemak: around text object"),
    map({ "x", "o" }, "rn", function() select_node(false) end, "Colemak: select or shrink syntax node"),
    map({ "x", "o" }, "tn", function() select_node(true) end, "Colemak: select or expand syntax node"),
    map({ "x", "o" }, "rh", ":<C-U>Gitsigns select_hunk<CR>", "Colemak: inner Git hunk"),
    map("x", "R", "r", "Colemak: replace selection"),
    map({ "n", "x" }, "bf", "zf", "Colemak: create fold"),
    map({ "n", "x" }, "bF", "zF", "Colemak: create counted fold"),
    map("n", "bd", "zd", "Colemak: delete fold"),
    map("n", "bD", "zD", "Colemak: delete folds recursively"),
    map("n", "bE", "zE", "Colemak: delete all folds"),
    map("n", "ba", "za", "Colemak: toggle fold"),
    map("n", "bA", "zA", "Colemak: toggle folds recursively"),
    map("n", "bo", "zo", "Colemak: open fold"),
    map("n", "bO", "zO", "Colemak: open folds recursively"),
    map("n", "bc", "zc", "Colemak: close fold"),
    map("n", "bC", "zC", "Colemak: close folds recursively"),
    map("n", "bM", "zM", "Colemak: close all folds"),
    map("n", "bR", "zR", "Colemak: open all folds"),
    map("n", "bm", "zm", "Colemak: fold more"),
    map("n", "br", "zr", "Colemak: fold less"),
    map({ "n", "x" }, "be", "zj", "Colemak: next fold"),
    map({ "n", "x" }, "bu", "zk", "Colemak: previous fold"),
    map("n", "bn", "zn", "Colemak: disable folds"),
    map("n", "bN", "zN", "Colemak: enable folds"),
    map("n", "bi", "zi", "Colemak: toggle folds"),
    map("n", "bx", "zx", "Colemak: update folds"),
    map("n", "bX", "zX", "Colemak: update all folds"),
    map("n", "bs", "zv", "Colemak: open enough folds"),
    map("n", "b=", "z=", "Colemak: spelling suggestions"),
    map("n", "bt", "zt", "Colemak: cursor to top"),
    map("n", "bb", "zb", "Colemak: cursor to bottom"),
    map("n", "bK", peek_fold, "Colemak: peek fold or hover"),
    map({ "n", "x" }, "[b", "[z", "Colemak: fold start"),
    map({ "n", "x" }, "]b", "]z", "Colemak: fold end"),
    map({ "n", "x", "o" }, "c", "y", "Colemak: copy"),
    map("n", "C", "y$", "Colemak: copy to end of line"),
    map("x", "C", "y", "Colemak: copy selection"),
    map("n", "v", "p", "Colemak: paste after"),
    map("x", "v", '"_dP', "Colemak: paste without yanking"),
    map({ "n", "x" }, "V", "P", "Colemak: paste before"),
    map("n", "X", "dd", "Colemak: cut line"),
    map("x", "X", "d", "Colemak: cut selection"),
    map({ "n", "x" }, "gv", "gp", "Colemak: paste after and leave cursor after"),
    map({ "n", "x" }, "gV", "gP", "Colemak: paste before and leave cursor after"),
    map("n", "z", "u", "Colemak: undo", { nowait = true }),
    map("n", "gz", "U", "Colemak: restore changed line"),
    map("n", "Z", "<C-r>", "Colemak: redo"),
    map("n", "s", "i", "Colemak: insert"),
    map("n", "S", "I", "Colemak: insert at first non-blank"),
    map("n", "t", "a", "Colemak: append"),
    map("n", "T", "A", "Colemak: append at end of line"),
    map({ "n", "x" }, "w", "c", "Colemak: change"),
    map({ "n", "x" }, "W", "C", "Colemak: change to end of line"),
    map("n", "ww", "cc", "Colemak: change line"),
    map({ "n", "x" }, "a", "v", "Colemak: visual mode"),
    map({ "n", "x" }, "A", "V", "Colemak: visual line mode"),
    map("n", "ga", "gv", "Colemak: reselect last selection"),
    map("x", "U", ":m '<-2<CR>gv=gv", "Colemak: move selection up"),
    map("x", "E", ":m '>+1<CR>gv=gv", "Colemak: move selection down"),
    map({ "n", "x", "o" }, "k", "n", "Colemak: next search result"),
    map({ "n", "x", "o" }, "K", "N", "Colemak: previous search result"),
    map({ "n", "x", "o" }, "p", "t", "Colemak: until next character"),
    map({ "n", "x", "o" }, "P", "T", "Colemak: until previous character"),
    map("n", "gdp", function() execute_original("dp") end, "Colemak: diff put"),
    map("n", "gdo", function() execute_original("do") end, "Colemak: diff get"),
    map("n", "Q", "@q", "Colemak: replay q macro"),
    map({ "n", "x" }, "B", "L", "Colemak: bottom of screen"),
    map({ "n", "x" }, "gH", "H", "Colemak: top of screen"),
    map({ "n", "x" }, "gL", "L", "Colemak: bottom of screen"),
    map({ "n", "x" }, "gX", "X", "Colemak: delete backward"),
    map({ "n", "x" }, "gQ", "Q", "Colemak: Ex mode"),
    map({ "n", "x" }, "gK", function() lookup() end, "Colemak: lookup or hover"),
    map({ "n", "x" }, "gh", function() lookup() end, "Colemak: lookup or hover"),
    map("n", "gS", "gI", "Colemak: insert at column one"),
    map({ "n", "x", "o" }, "gsi", "<Plug>(leap-forward)", "Colemak: Leap forward", { remap = true }),
    map({ "n", "x", "o" }, "gsn", "<Plug>(leap-backward)", "Colemak: Leap backward", { remap = true }),
    map("n", "<M-n>", "<M-h>", "Colemak: scroll viewport left 10%", { remap = true }),
    map("n", "<M-u>", "<M-k>", "Colemak: scroll viewport up 10%", { remap = true }),
    map("n", "<M-e>", "<M-j>", "Colemak: scroll viewport down 10%", { remap = true }),
    map("n", "<M-i>", "<M-l>", "Colemak: scroll viewport right 10%", { remap = true }),
    map({ "n", "x" }, "<C-n>", "<Esc><C-w>h", "Colemak: navigate window left"),
    map({ "n", "x" }, "<C-u>", "<Esc><C-w>k", "Colemak: navigate window up"),
    map({ "n", "x" }, "<C-e>", "<Esc><C-w>j", "Colemak: navigate window down"),
    map({ "n", "x" }, "<C-i>", "<Esc><C-w>l", "Colemak: navigate window right"),
    map({ "n", "x" }, "<C-w>n", "<C-w>h", "Colemak: window left"),
    map({ "n", "x" }, "<C-w>u", "<C-w>k", "Colemak: window up"),
    map({ "n", "x" }, "<C-w>e", "<C-w>j", "Colemak: window down"),
    map({ "n", "x" }, "<C-w>i", "<C-w>l", "Colemak: window right"),
    map({ "n", "x" }, "<C-w>N", "<C-w>H", "Colemak: move window left"),
    map({ "n", "x" }, "<C-w>U", "<C-w>K", "Colemak: move window up"),
    map({ "n", "x" }, "<C-w>E", "<C-w>J", "Colemak: move window down"),
    map({ "n", "x" }, "<C-w>I", "<C-w>L", "Colemak: move window right"),
    map("n", "<leader>wN", ":vertical resize -5<CR>", "Colemak: decrease width"),
    map("n", "<leader>wI", ":vertical resize +5<CR>", "Colemak: increase width"),
    map("n", "<leader>wU", ":resize +5<CR>", "Colemak: increase height"),
    map("n", "<leader>wE", ":resize -5<CR>", "Colemak: decrease height"),
    map("n", "<leader>bn", ":BufferLineCyclePrev<CR>", "Colemak: previous buffer"),
    map("n", "<leader>bi", ":BufferLineCycleNext<CR>", "Colemak: next buffer"),
    map("n", "<leader>bN", ":BufferLineMovePrev<CR>", "Colemak: move buffer left"),
    map("n", "<leader>bI", ":BufferLineMoveNext<CR>", "Colemak: move buffer right"),
    map("i", "<M-n>", "<Left>", "Colemak: move left"),
    map("i", "<M-u>", "<Up>", "Colemak: move up"),
    map("i", "<M-e>", "<Down>", "Colemak: move down"),
    map("i", "<M-i>", "<Right>", "Colemak: move right"),
    map("c", "<M-n>", "<Left>", "Colemak: move left"),
    map("c", "<M-u>", "<Up>", "Colemak: move up"),
    map("c", "<M-e>", "<Down>", "Colemak: move down"),
    map("c", "<M-i>", "<Right>", "Colemak: move right"),
    map("i", "<M-N>", "<Left><Left><Left><Left><Left>", "Colemak: move left five"),
    map("i", "<M-U>", "<Up><Up><Up><Up><Up>", "Colemak: move up five"),
    map("i", "<M-E>", "<Down><Down><Down><Down><Down>", "Colemak: move down five"),
    map("i", "<M-I>", "<Right><Right><Right><Right><Right>", "Colemak: move right five"),
    map("c", "<M-N>", "<Left><Left><Left><Left><Left>", "Colemak: move left five"),
    map("c", "<M-U>", "<Up><Up><Up><Up><Up>", "Colemak: move up five"),
    map("c", "<M-E>", "<Down><Down><Down><Down><Down>", "Colemak: move down five"),
    map("c", "<M-I>", "<Right><Right><Right><Right><Right>", "Colemak: move right five"),
    map("t", "<C-n>", [[<C-\><C-n><C-w>h]], "Colemak: navigate window left"),
    map("t", "<C-u>", [[<C-\><C-n><C-w>k]], "Colemak: navigate window up"),
    map("t", "<C-e>", [[<C-\><C-n><C-w>j]], "Colemak: navigate window down"),
    map("t", "<C-i>", [[<C-\><C-n><C-w>l]], "Colemak: navigate window right"),
  }
end

local function normalize(lhs)
  local termcodes = vim.api.nvim_replace_termcodes(lhs, true, true, true)
  return vim.fn.keytrans(termcodes)
end

local function find_global_mapping(mode, lhs)
  local normalized = normalize(lhs)
  for _, existing in ipairs(vim.api.nvim_get_keymap(mode)) do
    if normalize(existing.lhs) == normalized then
      return existing
    end
  end
end

local function find_buffer_mapping(bufnr, mode, lhs)
  local normalized = normalize(lhs)
  for _, existing in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
    if normalize(existing.lhs) == normalized then
      return existing
    end
  end
end

local function snapshot_key(mode, lhs)
  return mode .. "\31" .. normalize(lhs)
end

local function capture_mapping(mode, lhs)
  local id = snapshot_key(mode, lhs)
  if snapshots[id] then
    return
  end

  local existing = find_global_mapping(mode, lhs)
  if existing then
    snapshots[id] = { exists = true, mapping = existing }
    return
  end

  snapshots[id] = { exists = false, lhs = lhs }
end

local function remove_global_mappings()
  for _, mapping in ipairs(removed_global_mappings) do
    capture_mapping(mapping.mode, mapping.lhs)
    pcall(vim.keymap.del, mapping.mode, mapping.lhs)
  end
end

local function buffer_snapshot_key(bufnr, mode, lhs)
  return bufnr .. "\31" .. mode .. "\31" .. normalize(lhs)
end

local function capture_buffer_mapping(bufnr, mode, lhs)
  local id = buffer_snapshot_key(bufnr, mode, lhs)
  if buffer_snapshots[id] then
    return
  end

  local existing = find_buffer_mapping(bufnr, mode, lhs)
  if existing then
    buffer_snapshots[id] = {
      bufnr = bufnr,
      mode = mode,
      lhs = lhs,
      exists = true,
      mapping = existing,
    }
    return
  end

  buffer_snapshots[id] = {
    bufnr = bufnr,
    mode = mode,
    lhs = lhs,
    exists = false,
  }
end

local function set_buffer_mapping(bufnr, mode, lhs, rhs, desc)
  capture_buffer_mapping(bufnr, mode, lhs)
  vim.keymap.set(mode, lhs, rhs, {
    buffer = bufnr,
    desc = desc,
    silent = true,
  })
end

local function remove_buffer_mapping(bufnr, mode, lhs)
  if not find_buffer_mapping(bufnr, mode, lhs) then
    return
  end
  capture_buffer_mapping(bufnr, mode, lhs)
  pcall(vim.keymap.del, mode, lhs, { buffer = bufnr })
end

local function restore_mapping(mode, snapshot, bufnr)
  if not snapshot.exists then
    return
  end

  local existing = snapshot.mapping
  local rhs = existing.callback
  if not rhs then
    rhs = existing.rhs
  end
  if not rhs or rhs == "" then
    rhs = "<Nop>"
  end

  local opts = {
    desc = existing.desc,
    expr = existing.expr == 1,
    silent = existing.silent == 1,
    nowait = existing.nowait == 1,
    remap = existing.noremap == 0,
  }
  if existing.expr == 1 then
    opts.replace_keycodes = existing.replace_keycodes == 1
  end
  if bufnr then
    opts.buffer = bufnr
  end

  vim.keymap.set(mode, existing.lhs, rhs, opts)
end

local function restore_removed_global_mappings()
  for _, mapping in ipairs(removed_global_mappings) do
    local snapshot = snapshots[snapshot_key(mapping.mode, mapping.lhs)]
    if snapshot then
      restore_mapping(mapping.mode, snapshot)
    end
  end
end

local function restore_buffer_mappings()
  for _, snapshot in pairs(buffer_snapshots) do
    if vim.api.nvim_buf_is_valid(snapshot.bufnr) then
      pcall(vim.keymap.del, snapshot.mode, snapshot.lhs, { buffer = snapshot.bufnr })
      restore_mapping(snapshot.mode, snapshot, snapshot.bufnr)
    end
  end
  buffer_snapshots = {}
end

local function apply_lsp_buffer(bufnr)
  if not active or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  set_buffer_mapping(bufnr, "n", "K", "N", "Colemak: previous search result")
  set_buffer_mapping(bufnr, "n", "gK", function() lookup() end, "Colemak: hover documentation")
end

local function apply_lsp_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then
      apply_lsp_buffer(bufnr)
    end
  end
end

local function apply_nvim_tree_buffer(bufnr)
  if not active or not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "NvimTree" then
    return
  end

  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    return
  end

  set_buffer_mapping(bufnr, "n", "n", api.node.navigate.parent_close, "Colemak: close directory")
  set_buffer_mapping(bufnr, "n", "u", normal_counted("k"), "Colemak: move up")
  set_buffer_mapping(bufnr, "n", "e", normal_counted("j"), "Colemak: move down")
  set_buffer_mapping(bufnr, "n", "i", api.node.open.edit, "Colemak: open node")
  set_buffer_mapping(bufnr, "n", "gU", api.fs.rename_full, "Colemak: rename full path")
  set_buffer_mapping(bufnr, "n", "gE", api.fs.rename_basename, "Colemak: rename basename")
end

local dap_filetypes = {
  dapui_breakpoints = true,
  dapui_hover = true,
  dapui_scopes = true,
  dapui_stacks = true,
  dapui_watches = true,
}

local function apply_dap_buffer(bufnr)
  if not active or not vim.api.nvim_buf_is_valid(bufnr) or not dap_filetypes[vim.bo[bufnr].filetype] then
    return
  end

  local edit
  local current_edit = find_buffer_mapping(bufnr, "n", "e")
  local edit_snapshot = buffer_snapshots[buffer_snapshot_key(bufnr, "n", "e")]
  if current_edit and current_edit.desc ~= "Colemak: move down" then
    edit = current_edit
    if edit_snapshot then
      edit_snapshot.exists = true
      edit_snapshot.mapping = current_edit
    end
  end
  if not edit and edit_snapshot and edit_snapshot.exists then
    edit = edit_snapshot.mapping
  end
  if edit then
    local rhs = edit.callback
    if not rhs then
      rhs = edit.rhs
    end
    set_buffer_mapping(bufnr, "n", "gE", rhs, "Colemak: edit DAP item")
  end

  set_buffer_mapping(bufnr, "n", "n", normal_counted("h"), "Colemak: move left")
  set_buffer_mapping(bufnr, "n", "u", normal_counted("k"), "Colemak: move up")
  set_buffer_mapping(bufnr, "n", "e", normal_counted("j"), "Colemak: move down")
  set_buffer_mapping(bufnr, "n", "i", normal_counted("l"), "Colemak: move right")
end

local function apply_gitsigns_buffer(bufnr)
  if not active or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  for _, mode in ipairs({ "x", "o" }) do
    local existing = find_buffer_mapping(bufnr, mode, "ih")
    if existing and existing.desc == "Select hunk" then
      remove_buffer_mapping(bufnr, mode, "ih")
    end
  end
end

local function apply_special_buffers()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].filetype == "NvimTree" then
      apply_nvim_tree_buffer(bufnr)
    end
    if dap_filetypes[vim.bo[bufnr].filetype] then
      apply_dap_buffer(bufnr)
    end
    apply_gitsigns_buffer(bufnr)
  end
end

local function save_layout(layout)
  vim.fn.mkdir(vim.fs.dirname(state_file), "p")
  local result = vim.fn.writefile({ layout }, state_file)
  if result ~= 0 then
    vim.notify("Could not save keyboard layout", vim.log.levels.ERROR)
  end
end

local function load_layout()
  if vim.fn.filereadable(state_file) == 1 then
    local lines = vim.fn.readfile(state_file, "", 1)
    if lines[1] == "colemak" then
      return "colemak"
    end
  end

  return "qwerty"
end

local function enable()
  if active then
    return
  end

  snapshots = {}
  buffer_snapshots = {}
  for _, mapping in ipairs(layout_mappings) do
    local modes = mapping.modes
    if type(modes) == "string" then
      modes = { modes }
    end
    for _, mode in ipairs(modes) do
      capture_mapping(mode, mapping.lhs)
    end

    local opts = vim.tbl_extend("force", mapping.opts, {
      desc = mapping.desc,
      silent = true,
    })
    vim.keymap.set(mapping.modes, mapping.lhs, mapping.rhs, opts)
  end
  remove_global_mappings()

  active = true
  apply_lsp_buffers()
  apply_special_buffers()
end

local function disable()
  if not active then
    return
  end

  restore_buffer_mappings()
  for i = #layout_mappings, 1, -1 do
    local mapping = layout_mappings[i]
    local modes = mapping.modes
    if type(modes) == "string" then
      modes = { modes }
    end
    for _, mode in ipairs(modes) do
      pcall(vim.keymap.del, mode, mapping.lhs)
      local snapshot = snapshots[snapshot_key(mode, mapping.lhs)]
      if snapshot then
        restore_mapping(mode, snapshot)
      end
    end
  end
  restore_removed_global_mappings()

  snapshots = {}
  active = false
end

local function set_layout(layout, persist, notify)
  if layout ~= "qwerty" and layout ~= "colemak" then
    vim.notify("Keyboard layout must be qwerty or colemak", vim.log.levels.ERROR)
    return
  end

  if layout == "colemak" then
    enable()
  else
    disable()
  end

  vim.g.keyboard_layout = layout
  if persist then
    save_layout(layout)
  end
  if notify then
    vim.notify("Keyboard layout: " .. layout)
  end
end

function M.setup()
  lookup = function()
    if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
      vim.lsp.buf.hover()
      return
    end
    vim.cmd("normal! K")
  end
  layout_mappings = build_mappings()

  vim.api.nvim_create_user_command("KeyboardLayout", function(command)
    if command.args == "" then
      vim.notify("Keyboard layout: " .. M.current())
      return
    end
    set_layout(command.args, true, true)
  end, {
    nargs = "?",
    complete = function()
      return { "qwerty", "colemak" }
    end,
  })

  vim.api.nvim_create_user_command("KeyboardLayoutToggle", function()
    M.toggle()
  end, {})

  vim.keymap.set("n", "<leader>uk", function()
    M.toggle()
  end, { desc = "Toggle QWERTY/Colemak layout" })

  local group = vim.api.nvim_create_augroup("KeyboardLayout", { clear = true })
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      vim.schedule(function()
        apply_lsp_buffer(args.buf)
        apply_gitsigns_buffer(args.buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "NvimTree", "dapui_*" },
    callback = function(args)
      vim.schedule(function()
        apply_nvim_tree_buffer(args.buf)
        apply_dap_buffer(args.buf)
        apply_gitsigns_buffer(args.buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    group = group,
    callback = function(args)
      vim.schedule(function()
        apply_gitsigns_buffer(args.buf)
        apply_dap_buffer(args.buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged" }, {
    group = group,
    callback = function(args)
      vim.schedule(function()
        apply_dap_buffer(args.buf)
      end)
    end,
  })

  set_layout(load_layout(), false, false)
end

function M.current()
  if active then
    return "colemak"
  end
  return "qwerty"
end

function M.set(layout)
  set_layout(layout, true, true)
end

function M.attach_buffer(bufnr)
  apply_gitsigns_buffer(bufnr)
end

function M.toggle()
  if active then
    set_layout("qwerty", true, true)
    return
  end
  set_layout("colemak", true, true)
end

return M
