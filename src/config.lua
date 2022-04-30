local make_class = require('make_class')

local class = make_class('Config')

function class._init(self)
    self.draw_fps = true
    self.run_profiler = false
end

return class
