local BaseUnit = require('game_screen.units.base_unit')

local parent = BaseUnit
local class = setmetatable({}, { __index = parent })
class.__index = class

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
    parent._init(self, class.Kind.HERO, position, class.Attrs.new(12, 14))
    return self
end

return class
