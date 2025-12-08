-- ~/.wezterm.lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Default Shell (uses system default - bash)

-- Font Configuration
config.font = wezterm.font('FiraCode Nerd Font', { weight = 'Medium' })
config.font_size = 13.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Color Scheme (Tokyo Night Storm - great for long coding sessions)
config.color_scheme = 'Tokyo Night Storm'
config.window_background_opacity = 0.95
config.macos_window_background_blur = 10

-- Performance
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 60
config.scrollback_lines = 10000

-- Window Configuration
config.initial_cols = 120
config.initial_rows = 35
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.window_decorations = "RESIZE"

-- Tab Bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_thickness = 2

-- Features
config.enable_scroll_bar = false
config.audible_bell = "Disabled"
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Key Bindings
config.keys = {
  -- Split panes
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  
  -- Navigate panes
  { key = 'h', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CMD|ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
  
  -- Adjust pane size
  { key = 'h', mods = 'CMD|SHIFT|ALT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'l', mods = 'CMD|SHIFT|ALT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  
  -- Quick select mode (for URLs and paths)
  { key = 'f', mods = 'CMD|SHIFT', action = wezterm.action.QuickSelect },
  
  -- Search mode
  { key = 'f', mods = 'CMD', action = wezterm.action.Search { CaseSensitiveString = '' } },
  
  -- Copy mode (vim-like scrolling)
  { key = 'x', mods = 'CMD|SHIFT', action = wezterm.action.ActivateCopyMode },
  
  -- Rename tab
  {
    key = 'r',
    mods = 'ALT',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  
  -- Move tab left/right
  { key = 'LeftArrow', mods = 'CMD|SHIFT', action = wezterm.action.MoveTabRelative(-1) },
  { key = 'RightArrow', mods = 'CMD|SHIFT', action = wezterm.action.MoveTabRelative(1) },
}

-- Mouse bindings
config.mouse_bindings = {
  -- Open links with Cmd+Click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CMD',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

return config
