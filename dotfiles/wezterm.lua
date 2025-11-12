local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "catppuccin-mocha"

config.use_fancy_tab_bar = false
-- config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "NONE"
config.enable_wayland = false -- fixes problems with tab/title bar

config.window_background_opacity = 0.95

return config
