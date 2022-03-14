local BaseUnit = require('game_screen.units.base_unit')

local parent = BaseUnit
local class = setmetatable({}, { __index = parent })
class.__index = class

function class.new(position)
    local self = setmetatable({}, class)
    self.xp_bounty = 1
    parent._init(self, class.Kind.RAT, position, class.Attrs.new(7, 15))
    return self
end

return class
