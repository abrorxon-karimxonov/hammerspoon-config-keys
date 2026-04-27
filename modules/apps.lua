-- App launcher module
-- Binds hyper + key to launch or focus apps

local M = {}

function M.setup(hyper)
    local appConfig = require("config.apps")

    for name, app in pairs(appConfig) do
        hs.hotkey.bind(hyper, app.key, function()
            hs.application.launchOrFocusByBundleID(app.id)
        end)

        -- shift + ctrl + key: quit app in background without activating it
        hs.hotkey.bind({"shift", "ctrl"}, app.key, function()
            local running = hs.application.applicationsForBundleID(app.id)
            if running and #running > 0 then
                running[1]:kill()
            end
        end)
    end
end

return M
