-- Hammerspoon configuration
-- Modules are loaded from the modules/ directory

local hyper = {"cmd", "alt", "ctrl", "shift"}

-- Load modules
require("modules.hyper").setup()
require("modules.scroll").setup()
require("modules.apps").setup(hyper)
require("modules.brightness").setup()
require("zen_restart")

-- Reload config with Hyper + R
hs.hotkey.bind(hyper, "R", function()
    hs.reload()
end)

hs.alert.show("Config Loaded")
