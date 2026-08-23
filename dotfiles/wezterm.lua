local wezterm = require("wezterm")
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Same look as ~/.wezterm.lua + wezterm-crt (minus the CRT shader fork).
config.color_scheme = "Homebrew (Gogh)"

config.font = wezterm.font_with_fallback({
	"BigBlueTerm437 Nerd Font",
	"BigBlueTerm437 Nerd Font Mono",
	"Symbols Nerd Font Mono",
})
config.font_size = 15
config.line_height = 1.1
config.text_background_opacity = 1.0
config.foreground_text_hsb = {
	hue = 1.0,
	saturation = 1.4,
	brightness = 1.15,
}

config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 1.0
config.initial_cols = 120
config.initial_rows = 40

config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "0.5cell",
	bottom = "0.5cell",
}

config.window_decorations = "RESIZE"
config.text_blink_rate = 110
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 110
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.colors = {
	background = "#000000",
	foreground = "#00ff00",
	cursor_bg = "#23ff18",
	cursor_fg = "#ff0018",
	cursor_border = "#23ff18",
	selection_bg = "#083905",
	selection_fg = "#ffffff",
}

config.keys = {
	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendKey({ key = "b", mods = "ALT" }),
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendKey({ key = "f", mods = "ALT" }),
	},
	{
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.SendKey({ key = "b", mods = "ALT" }),
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.SendKey({ key = "f", mods = "ALT" }),
	},
}

return config
