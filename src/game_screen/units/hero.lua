local BaseUnit = require('game_screen.units.base_unit')
local make_class = require('make_class')

local class = make_class(
    'Hero',
    {
        _parent = BaseUnit
    }
)

function class.next_level_xp(level)
    return level ^ 2
end

function class.new(position)
    local level = 1
    local self = {
        class = class,
        level = level,
        xp = 0,
        next_level_xp = class.next_level_xp(level)
    }
    setmetatable(self, class)
    class.parent._init(self, class.Kind.HERO, position, class.Attrs.new(12, 14))
    return self
end

return class
