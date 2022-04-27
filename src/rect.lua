local make_class = require('make_class')
local utils = require('utils')

local class = make_class(
    'Rect',
    {
        _to_string =  utils.make_to_string('Rect', 'x', 'y', 'width', 'height')
    }
)

function class._init(self, x, y, width, height)
    assert(x)
    assert(y)
    assert(width)
    assert(height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function class:contains(x, y)
    return x >= self.x
        and x < self.x + self.width
        and y >= self.y
        and y < self.y + self.height
end

return class
