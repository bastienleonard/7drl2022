local StackView = require('ui.stack_view')

local parent = StackView
local class = setmetatable({}, { __index = parent })
class.__index = class

function class.new(options)
    local self = {}
    options.orientation = StackView.Orientation.HORIZONTAL
    parent._init(self, options)
    return setmetatable(self, class)
end

function class:__tostring()
    return 'RowView'
end

return class
