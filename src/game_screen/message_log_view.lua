local BaseView = require('ui.base_view')
local utils = require('utils')

local parent = BaseView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function init(self, options)
end

function class.new(options)
    local self = {}
    setmetatable(self, class)
    parent._init(self, options)
    init(self, options)
    return self
end

function class:__tostring()
    return 'MessagesLogView'
end

function class:measure(options)
    self:set_measured(options.max_width, options.max_height)
end

function class:draw(x, y)
    parent.draw(self, x, y)

    if self.measured_width == 0 or self.measured_height == 0 then
        return
    end

    local messages = globals.screens:current().messages

    for i = 1, self.measured_height do
        local offset = 0

        if #messages > self.measured_height then
            offset = #messages - self.measured_height
        end

        local message = messages[i + offset]

        if not message then
            break
        end

        self:draw_text(
            message,
            x,
            y + i - 1,
            { max_width = self.measured_width }
        )
    end
end

return class