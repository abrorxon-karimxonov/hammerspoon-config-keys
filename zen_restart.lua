-- Zen Browser Restart Script for Hammerspoon
-- This script provides multiple methods to restart Zen without confirmation dialogs

local zen = {}

-- Method 1: Force quit and relaunch (most reliable)
function zen.forceRestart()
    -- Kill all Zen processes
    os.execute("killall zen 2>/dev/null")
    -- Wait a moment for processes to terminate
    hs.timer.doAfter(1, function()
        -- Relaunch Zen
        hs.application.launchOrFocus("Zen")
    end)
end

-- Method 2: Use AppleScript to quit without saving
function zen.scriptRestart()
    local script = [[
        tell application "Zen"
            quit without saving
        end tell
    ]]
    hs.osascript.applescript(script)
    
    -- Wait and relaunch
    hs.timer.doAfter(2, function()
        hs.application.launchOrFocus("Zen")
    end)
end

-- Method 3: Send CMD+Q and handle dialog with keystroke
function zen.keystrokeRestart()
    local zenApp = hs.application.find("Zen")
    if zenApp then
        zenApp:activate()
        hs.timer.doAfter(0.5, function()
            -- Send CMD+Q
            hs.eventtap.keyStroke({"cmd"}, "q")
            
            -- Wait a bit then press Enter or Space to confirm
            hs.timer.doAfter(0.5, function()
                hs.eventtap.keyStroke({}, "return") -- or use "space"
            end)
            
            -- Relaunch after quit
            hs.timer.doAfter(2, function()
                hs.application.launchOrFocus("Zen")
            end)
        end)
    else
        -- If not running, just launch it
        hs.application.launchOrFocus("Zen")
    end
end

-- Method 4: Native macOS terminate and relaunch (cleanest)
function zen.nativeRestart()
    local zenApp = hs.application.find("Zen")
    if zenApp then
        -- Force terminate without asking
        zenApp:kill9()
        
        -- Wait and relaunch
        hs.timer.doAfter(1, function()
            hs.application.launchOrFocus("Zen")
        end)
    else
        hs.application.launchOrFocus("Zen")
    end
end

-- Method 5: Memory cleanup restart (kills leaky processes first)
function zen.memoryCleanRestart()
    -- Kill all zen processes including plugin containers
    os.execute("pgrep -f zen | xargs kill -9 2>/dev/null")
    
    -- Wait for cleanup
    hs.timer.doAfter(2, function()
        hs.application.launchOrFocus("Zen")
    end)
end

-- Bind to hotkeys (uncomment the one you prefer)
-- hs.hotkey.bind({"cmd", "shift"}, "R", zen.forceRestart)        -- Most reliable
-- hs.hotkey.bind({"cmd", "shift"}, "R", zen.nativeRestart)       -- Cleanest
-- hs.hotkey.bind({"cmd", "shift"}, "R", zen.memoryCleanRestart)  -- Best for memory leaks

-- Helper: get Zen memory usage in GB as a string
local function zenMemoryStr()
    local handle = io.popen("pgrep -f zen | xargs ps -o rss= 2>/dev/null | awk '{sum+=$1} END {print sum/1024}'")
    local result = handle:read("*a")
    handle:close()
    local mb = tonumber(result) or 0
    if mb == 0 then return nil end
    return string.format("%.1fGB", mb / 1024)
end

-- Helper: pick an emoji based on memory level
local function memEmoji(memStr)
    if not memStr then return "🔄" end
    local gb = tonumber(memStr:match("([%d%.]+)")) or 0
    if gb >= 4 then return "🚨"
    elseif gb >= 3 then return "⚠️"
    elseif gb >= 2 then return "🟡"
    else return "🔄" end
end


-- Menu bar item (stored on zen table to prevent garbage collection)
zen.menu = hs.menubar.new()
if zen.menu then
    zen.menu:setTitle("🔄 Zen")
    zen.menu:setMenu({
        {title = "📊 Check Memory", fn = function()
            local mem = zenMemoryStr()
            if mem then
                local icon = memEmoji(mem)
                hs.alert.show(icon .. " Zen Memory: " .. mem, 3)
            else
                hs.alert.show("🔄 Zen is not running", 2)
            end
        end},
        {title = "-"},
        {title = "♻️  Restart (Clean Memory)", fn = zen.memoryCleanRestart},
        {title = "💨 Restart (Force)",        fn = zen.forceRestart},
        {title = "🍎 Restart (Native)",        fn = zen.nativeRestart},
        {title = "-"},
        {title = "🚀 Launch Zen", fn = function() hs.application.launchOrFocus("Zen") end},
    })
end

return zen
