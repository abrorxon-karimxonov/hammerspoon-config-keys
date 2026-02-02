-- App launcher module
-- Binds hyper + key to launch or focus apps

local M = {}

function M.setup(hyper)
    local appConfig = require("config.apps")

    for name, app in pairs(appConfig) do
        hs.hotkey.bind(hyper, app.key, function()
            hs.application.launchOrFocusByBundleID(app.id)
        end)
    end
end

return M
