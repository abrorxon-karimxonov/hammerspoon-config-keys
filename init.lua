-- Hammerspoon configuration
-- Modules are loaded from the modules/ directory

local hyper = {"cmd", "alt", "ctrl", "shift"}
hs.window.animationDuration = 0

-- Load modules
require("modules.hyper").setup()
-- require("modules.scroll").setup()
require("modules.apps").setup(hyper)
require("modules.brightness").setup()
require("zen_restart")

-- Move focused window to next monitor
hs.hotkey.bind(hyper, "Down", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    local screen = win:screen()
    local nextScreen = screen:next()
    if nextScreen == screen then return end
    win:moveToScreen(nextScreen, true, true)
end)

-- Toggle maximize window (like Cmd+click green button)
local previousFrames = {}
hs.hotkey.bind(hyper, "Return", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    local id = win:id()
    local maxFrame = win:screen():frame()
    local currentFrame = win:frame()

    if previousFrames[id] and currentFrame:equals(maxFrame) then
        win:setFrame(previousFrames[id])
        previousFrames[id] = nil
    else
        previousFrames[id] = currentFrame
        win:maximize()
    end
end)

require("modules.cursor").setup(hyper)

-- Reload config with Hyper + R
hs.hotkey.bind(hyper, "R", function()
    hs.reload()
end)

hs.alert.show("Config Loaded")
