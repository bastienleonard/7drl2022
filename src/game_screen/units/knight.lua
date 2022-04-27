local BaseUnit = require('game_screen.units.base_unit')
local make_class = require('make_class')

local class = make_class(
    'Knight',
    {
        _parent = BaseUnit
    }
)

function class.new(position)
    local self = setmetatable({}, class)
    self.xp_bounty = 5
    class.parent._init(
        self,
        class.Kind.KNIGHT,
        position,
        class.Attrs.new(12, 15)
    )
    return self
end

return class
