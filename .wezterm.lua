-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

local act = wezterm.action

config.default_prog = { "nu" }

config.color_scheme = "tokyonight"

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11

config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 1

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.88
config.window_background_gradient = {
  interpolation = 'Linear',

  orientation = 'Vertical',

  blend = 'Rgb',

  colors = {
    '#11111b',
    '#181825',
  },
}

-- Disable "Really kill this window?" prompt
config.window_close_confirmation = "NeverPrompt"

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
    --  Splits 
    { key = "s", mods = "LEADER", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	{ key = "d", mods = "LEADER", action = act.SplitPane({ direction = "Down",  size = { Percent = 50 } }) },


    --  Pane navigation (Alt+hjkl, safe in Neovim) 
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

    --  Pane resizing (Leader + arrow keys)
    { key = "LeftArrow",  mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "RightArrow", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "UpArrow",    mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "DownArrow",  mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },

    --  Pane management 
    { key = "w", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },   -- "zoom" a pane fullscreen
    { key = "p", mods = "LEADER", action = act.PaneSelect },             -- visual picker

    --  Tabs 
    { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
    { key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
}

-- and finally, return the configuration to wezterm
return config
