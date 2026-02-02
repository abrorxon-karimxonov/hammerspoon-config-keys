-- Mouse scroll reversal module
-- Reverses scroll direction for physical mouse wheel while keeping trackpad natural

local M = {}

local scrollTap = nil

function M.setup()
    scrollTap = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
        -- Check if the event is from a continuous scroll (Trackpad/Magic Mouse)
        -- If it's 0, it's usually a physical scroll wheel
        local isContinuous = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)

        if isContinuous == 0 then
            local deltaY = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1)
            local deltaX = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2)

            -- Reverse the vertical and horizontal scroll
            event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1, deltaY * -1)
            event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2, deltaX * -1)
        end
        return false
    end)

    scrollTap:start()
end

function M.stop()
    if scrollTap then
        scrollTap:stop()
    end
end

return M
