local utils = require('utils')

local class = {
    __tostring = utils.make_to_string('Rect', 'x', 'y', 'width', 'height')
}
class.__index = class

function class.new(x, y, width, height)
    assert(x)
    assert(y)
    assert(width)
    assert(height)
    local self = {}
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    return setmetatable(self, class)
end

function class:contains(x, y)
    return x >= self.x
        and x < self.x + self.width
        and y >= self.y
        and y < self.y + self.height
end

return class
