local BaseUnit = require('game_screen.units.base_unit')
local make_class = require('make_class')

local class = make_class(
    'Demon',
    {
        _parent = BaseUnit
    }
)

function class.new(position)
    local self = setmetatable({}, class)
    self.xp_bounty = 10
    class.parent._init(
        self,
        class.Kind.DEMON,
        position,
        class.Attrs.new(15, 15)
    )
    return self
end

return class
