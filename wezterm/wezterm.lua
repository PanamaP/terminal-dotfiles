local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local projects = require("projects")

projects.project_dirs= { "C:\\Dev" }

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

wezterm.on("user-var-changed", function(window, name, value)
  if name == "NVIM" then
    local overrides = window:get_config_overrides() or {}
    if value == "1" then
      overrides.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
    else
      overrides.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
    end
    window:set_config_overrides(overrides)
  end
end)

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

local function segments_for_right_status(window)
  return {
    '󱂬 ' .. window:active_workspace(),
    ' ' .. wezterm.strftime('%a %b %-d %H:%M'),
    '󰒋 ' .. wezterm.hostname(),
  }
end

wezterm.on('update-status', function(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  -- Note the use of wezterm.color.parse here, this returns
  -- a Color object, which comes with functionality for lightening
  -- or darkening the colour (amongst other things).
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Each powerline segment is going to be coloured progressively
  -- darker/lighter depending on whether we're on a dark/light colour
  -- scheme. Let's establish the "from" and "to" bounds of our gradient.
  local gradient_to, gradient_from = bg
  gradient_from = gradient_to:lighten(0.2)

  -- Yes, WezTerm supports creating gradients, because why not?! Although
  -- they'd usually be used for setting high fidelity gradients on your terminal's
  -- background, we'll use them here to give us a sample of the powerline segment
  -- colours we need.
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)

return config
