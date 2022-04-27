local make_class = require('make_class')
local StackView = require('ui.stack_view')

local class = make_class(
    'ColumnView',
    {
        _parent = StackView
    }
)

function class._init(self, options)
    options.orientation = StackView.Orientation.VERTICAL
    class.parent._init(self, options)
end

return class
