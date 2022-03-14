local BaseScreen = require('base_screen')
local TextView = require('ui.text_view')
local utils = require('utils')

local parent = BaseScreen
local class = setmetatable({}, { __index = parent })
class.__index = class

function class.new()
    local self = {}
    parent._init(self)
    return setmetatable(self, class)
end

function class:draw()
    local terminal = globals.terminal
    local text = TextView.new({ text = 'You died' })
    text:measure()
    text:draw(
        math.max(0, utils.round((terminal.width - text.measured_width) / 2)),
        math.max(0, utils.round((terminal.height - text.measured_height) / 2))
    )
end

return class
