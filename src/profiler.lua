local profile

local module = {}

local started = false
local profiler_time = 0

function module.start()
    started = true
    profile = require('vendor.profile.profile')
    profile.start()
end

function module.update(dt)
    if not started then
        return
    end

    profiler_time = profiler_time + dt

    if profiler_time >= 10 then
        print(profile.report(20))
        love.event.quit()
    end
end

return module
