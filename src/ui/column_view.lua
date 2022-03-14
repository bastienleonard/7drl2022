local StackView = require('ui.stack_view')

local parent = StackView
local class = setmetatable({}, { __index = parent })
class.__index = class

function class._init(self, options)
    options.orientation = StackView.Orientation.VERTICAL
    parent._init(self, options)
end

function class.new(options)
    local self = {}
    class._init(self, options)
    return setmetatable(self, class)
end

function class:__tostring()
    return 'ColumnView'
end

return class
