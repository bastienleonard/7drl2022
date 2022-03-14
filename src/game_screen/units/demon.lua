local BaseUnit = require('game_screen.units.base_unit')

local parent = BaseUnit
local class = setmetatable({}, { __index = parent })
class.__index = class

function class.new(position)
    local self = setmetatable({}, class)
    self.xp_bounty = 10
    parent._init(self, class.Kind.DEMON, position, class.Attrs.new(15, 15))
    return self
end

return class
