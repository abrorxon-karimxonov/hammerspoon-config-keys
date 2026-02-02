-- Caps Lock to Hyper key remapping module
-- Note: You may need Karabiner-Elements to first map Caps Lock to F18/F19

local M = {}

local hyperTap = nil

function M.setup()
    hyperTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(event)
        local keyCode = event:getKeyCode()

        -- 57 is the standard keycode for Caps Lock
        if keyCode == 57 then
            local isDown = event:getType() == hs.eventtap.event.types.keyDown

            local flags = {}
            if isDown then
                flags = {"cmd", "ctrl", "alt", "shift"}
            end

            return true, {hs.eventtap.event.newKeyEvent(flags, keyCode, isDown)}
        end

        return false
    end)

    hyperTap:start()
end

function M.stop()
    if hyperTap then
        hyperTap:stop()
    end
end

return M
