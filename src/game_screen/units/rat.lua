local BaseUnit = require('game_screen.units.base_unit')
local make_class = require('make_class')

local class = make_class(
    'Rat',
    {
        _parent = BaseUnit
    }
)

function class._init(self, position)
    self.xp_bounty = 1
    class.parent._init(self, class.Kind.RAT, position, class.Attrs.new(7, 15))
end

return class
