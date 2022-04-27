local make_class = require('make_class')
local StackView = require('ui.stack_view')

local class = make_class(
    'RowView',
    {
        _parent = StackView
    }
)

function class.new(options)
    local self = {}
    options.orientation = StackView.Orientation.HORIZONTAL
    class.parent._init(self, options)
    return setmetatable(self, class)
end

return class
