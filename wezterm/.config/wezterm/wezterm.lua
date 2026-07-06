-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }
config.keys = {
	-- CTRL+SHIFT+Space, followed by 'r' will put us in resize-pane
	-- mode until we cancel that mode.
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
		}),
	},
	{
		key = "y",
		mods = "LEADER",
		action = act.SwitchToWorkspace({
			name = "default",
		}),
	},
	-- Switch to a monitoring workspace, which will have `top` launched into it
	{
		key = "u",
		mods = "LEADER",
		action = act.SwitchToWorkspace({
			name = "monitoring",
			spawn = {
				args = { "/opt/homebrew/bin/zsh btop" },
			},
		}),
	},
}

config.key_tables = {
	-- Defines the keys that are active in our resize-pane mode.
	-- Since we're likely to want to make multiple adjustments,
	-- we made the activation one_shot=false. We therefore need
	-- to define a key assignment for getting out of this mode.
	-- 'resize_pane' here corresponds to the name="resize_pane" in
	-- the key assignments above.
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 5 }) },

		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
}

-- This is where you actually apply your config choices.
wezterm.on("update-right-status", function(window)
	window:set_right_status(window:active_workspace())
end)

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 18
config.font = wezterm.font("IosevkaTerm Nerd Font Mono")
config.color_scheme = "Gruvbox Dark (Gogh)"

-- This removes the close/resize bar at the top
config.window_decorations = "RESIZE"

-- Finally, return the configuration to wezterm:
return config
