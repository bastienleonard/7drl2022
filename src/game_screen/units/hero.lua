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

function class._init(self, position)
    local level = 1
    self.class = class
    self.level = level
    self.xp = 0
    self.next_level_xp = class.next_level_xp(level)
    class.parent._init(self, class.Kind.HERO, position, class.Attrs.new(12, 14))
end

return class
