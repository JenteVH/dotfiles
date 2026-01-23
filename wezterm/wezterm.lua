local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font('FiraCode Nerd Font', { weight = 'Medium' })
config.font_size = 13.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

config.color_scheme = 'Tokyo Night Storm'
config.window_background_opacity = 0.95

config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 60
config.scrollback_lines = 10000

config.initial_cols = 120
config.initial_rows = 35
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.window_decorations = "NONE"

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

config.default_cursor_style = 'SteadyBlock'

config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.keys = {
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = true } },

  { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  { key = '[', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection 'Next' },

  { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
  { key = ',', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '.', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },

  { key = 'f', mods = 'CTRL|SHIFT', action = act.Search { CaseSensitiveString = '' } },
  {
    key = 'r',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },

  { key = '+', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
  { key = '_', mods = 'CTRL|SHIFT', action = act.DecreaseFontSize },
  { key = ')', mods = 'CTRL|SHIFT', action = act.ResetFontSize },

  { key = 'LeftArrow', mods = 'CTRL', action = act.SendKey { key = 'b', mods = 'ALT' } },
  { key = 'RightArrow', mods = 'CTRL', action = act.SendKey { key = 'f', mods = 'ALT' } },
  { key = 'Backspace', mods = 'CTRL', action = act.SendKey { key = 'w', mods = 'CTRL' } },
  { key = 'Home', mods = 'CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'End', mods = 'CTRL', action = act.SendKey { key = 'e', mods = 'CTRL' } },

  {
    key = 'e',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      label = 'open url',
      patterns = { 'https?://[^\\s]+' },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end),
    },
  },
  {
    key = 'p',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      label = 'copy path',
      patterns = { '[~/]?[\\w.-]+(?:/[\\w.-]+)+' },
      action = wezterm.action_callback(function(window, pane)
        local path = window:get_selection_text_for_pane(pane)
        window:copy_to_clipboard(path, 'Clipboard')
      end),
    },
  },
  {
    key = 'o',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      label = 'copy file:line',
      patterns = { '[\\w./+-]+:\\d+' },
      action = wezterm.action_callback(function(window, pane)
        local ref = window:get_selection_text_for_pane(pane)
        window:copy_to_clipboard(ref, 'Clipboard')
      end),
    },
  },
  { key = 'Space', mods = 'CTRL|SHIFT', action = act.QuickSelect },

  { key = 'h', mods = 'CTRL|SHIFT', action = act.EmitEvent 'scrollback-to-vim' },
  { key = 'g', mods = 'CTRL|SHIFT', action = act.EmitEvent 'scrollback-to-less' },
}

wezterm.on('scrollback-to-vim', function(window, pane)
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
  local name = os.tmpname()
  local f = io.open(name, 'w+')
  f:write(text)
  f:flush()
  f:close()
  window:perform_action(
    act.SpawnCommandInNewTab {
      args = { 'vim', '-R', '+normal G', name },
    },
    pane
  )
  wezterm.sleep_ms(1000)
  os.remove(name)
end)

wezterm.on('scrollback-to-less', function(window, pane)
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
  local name = os.tmpname()
  local f = io.open(name, 'w+')
  f:write(text)
  f:flush()
  f:close()
  window:perform_action(
    act.SpawnCommandInNewTab {
      args = { 'less', '+G', name },
    },
    pane
  )
  wezterm.sleep_ms(1000)
  os.remove(name)
end)

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 2, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 3, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },

  {
    event = { Down = { streak = 1, button = 'Middle' } },
    mods = 'NONE',
    action = act.PasteFrom 'PrimarySelection',
  },

  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

return config
