local BaseUnit = require('game_screen.units.base_unit')

local parent = BaseUnit
local class = setmetatable({}, { __index = parent })
class.__index = class

function class.new(position)
    local self = setmetatable({}, class)
    self.xp_bounty = 5
    parent._init(self, class.Kind.KNIGHT, position, class.Attrs.new(12, 15))
    return self
end

return class
