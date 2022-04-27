local make_class = require('make_class')
local utils = require('utils')

local class = make_class(
    'Vec2',
    {
        _to_string = utils.make_to_string('Vec2', 'x', 'y')
    }
)

function class.new(x, y)
    assert(x)
    assert(y)
    local self = {
        x = x,
        y = y
    }
    return setmetatable(self, class)
end

function class:__eq(other)
    return self.x == other.x and self.y == other.y
end

function class:__add(other)
    return class.new(self.x + other.x, self.y + other.y)
end

class.LEFT = class.new(-1, 0)
class.RIGHT = class.new(1, 0)
class.UP = class.new(0, -1)
class.DOWN = class.new(0, 1)
class.LEFT_AND_UP = class.LEFT + class.UP
class.LEFT_AND_DOWN = class.LEFT + class.DOWN
class.RIGHT_AND_UP = class.RIGHT + class.UP
class.RIGHT_AND_DOWN = class.RIGHT + class.DOWN

return class
