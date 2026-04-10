local M = {}

local function showCursorRipple(cx, cy)
    local maxSize = 120
    local steps = 25
    local stepTime = 0.016 -- ~60fps
    local step = 0

    local c = hs.canvas.new({x = cx - maxSize, y = cy - maxSize, w = maxSize * 2, h = maxSize * 2})
    -- black outline ring
    c[1] = {
        type = "circle",
        center = {x = maxSize, y = maxSize},
        radius = 4,
        strokeColor = {red = 0, green = 0, blue = 0, alpha = 0.6},
        fillColor = {alpha = 0},
        strokeWidth = 6,
    }
    -- white inner ring
    c[2] = {
        type = "circle",
        center = {x = maxSize, y = maxSize},
        radius = 4,
        strokeColor = {red = 1, green = 1, blue = 1, alpha = 0.9},
        fillColor = {alpha = 0},
        strokeWidth = 3,
    }
    c:show()

    local timer
    timer = hs.timer.doEvery(stepTime, function()
        step = step + 1
        local progress = step / steps
        local radius = 4 + (maxSize - 4) * progress
        local alpha = 1 - progress
        c[1] = {
            type = "circle",
            center = {x = maxSize, y = maxSize},
            radius = radius,
            strokeColor = {red = 0, green = 0, blue = 0, alpha = 0.6 * alpha},
            fillColor = {alpha = 0},
            strokeWidth = 6,
        }
        c[2] = {
            type = "circle",
            center = {x = maxSize, y = maxSize},
            radius = radius,
            strokeColor = {red = 1, green = 1, blue = 1, alpha = 0.9 * alpha},
            fillColor = {alpha = 0},
            strokeWidth = 3,
        }
        if step >= steps then
            timer:stop()
            c:delete()
        end
    end)
end

function M.setup(hyper)
    hs.hotkey.bind(hyper, "\\", function()
        local win = hs.window.focusedWindow()
        if not win then return end
        local frame = win:frame()
        local cx = frame.x + frame.w / 2
        local cy = frame.y + frame.h / 2
        local point = hs.geometry.new(cx, cy)
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.mouseMoved, point):post()
        hs.mouse.setAbsolutePosition(point)
        showCursorRipple(cx, cy)
    end)
end

return M
