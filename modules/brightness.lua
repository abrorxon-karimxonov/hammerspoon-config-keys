-- Brightness sync module
-- Syncs external display brightness with built-in display

local M = {}

local brightnessTimer = nil
local lastBrightness = nil

-- Get list of external display IDs using m1ddc
local function getExternalDisplays()
    local output, status = hs.execute("/opt/homebrew/bin/m1ddc display list 2>/dev/null")
    if not status then return {} end

    local displays = {}
    for line in output:gmatch("[^\r\n]+") do
        local id = line:match("^%[(%d+)%]")
        if id then
            table.insert(displays, id)
        end
    end
    return displays
end

-- Set luminance on external display (0-100)
local function setExternalBrightness(displayId, brightness)
    local cmd = string.format("/opt/homebrew/bin/m1ddc display %s set luminance %d 2>/dev/null", displayId, brightness)
    hs.execute(cmd)
end

-- Sync all external displays to match built-in brightness
local function syncBrightness()
    local builtinBrightness = hs.brightness.get()
    if not builtinBrightness then return end

    local brightness = math.floor(builtinBrightness)

    -- Only sync if brightness changed
    if brightness == lastBrightness then return end
    lastBrightness = brightness

    local displays = getExternalDisplays()
    for _, displayId in ipairs(displays) do
        setExternalBrightness(displayId, brightness)
    end
end

function M.setup()
    -- Initial sync
    syncBrightness()

    -- Poll for brightness changes every 0.5 seconds
    brightnessTimer = hs.timer.new(0.5, syncBrightness)
    brightnessTimer:start()
end

function M.stop()
    if brightnessTimer then
        brightnessTimer:stop()
    end
end

-- Manual sync function
M.sync = syncBrightness

return M
