local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local projects = require("projects")

config.default_prog = { "nu" }

config.color_scheme = "tokyonight"

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11

config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 1

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.window_background_gradient = {
  interpolation = 'Linear',
  orientation = 'Vertical',
  blend = 'Rgb',
  colors = {
    '#11111b',
    '#181825',
  },
}

config.window_close_confirmation = "NeverPrompt"

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

local keys = {
  -- Splits
  { key = "s", mods = "LEADER", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
  { key = "d", mods = "LEADER", action = act.SplitPane({ direction = "Down",  size = { Percent = 50 } }) },

  -- Pane navigation
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

  -- Pane resizing
  { key = "LeftArrow",  mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "UpArrow",    mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "DownArrow",  mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },

  -- Pane management
  { key = "w", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- Tabs
  { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = 'LeftArrow', mods = 'SHIFT|ALT', action = act.MoveTabRelative(-1) },
  { key = 'RightArrow', mods = 'SHIFT|ALT', action = act.MoveTabRelative(1) },

  -- Workspaces (projects)
  { key = "p", mods = "LEADER",       action = projects.switch_workspace() },
  { key = "p", mods = "LEADER|SHIFT", action = projects.switch_to_prev_workspace() },
  { key = "f", mods = "LEADER", action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },
}

-- Tabs 1-9
for i = 1, 9 do
  table.insert(keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1),
  })
end

config.keys = keys

wezterm.on('update-status', function(window)
  local SOLID_LEFT_Arrow = utf8.char(0xe0b2)
  local color_scheme = window:effective_config().resolved_palette
  local bg = color_scheme.background
  local fg = color_scheme.foreground

  window:set_right_status(wezterm.format({
    { Background = { Color = 'none' } },
    { Foreground = { Color = bg } },
    { Text = SOLID_LEFT_Arrow },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = ' ' .. wezterm.hostname() .. ' ' },
  }))
end)

return config
