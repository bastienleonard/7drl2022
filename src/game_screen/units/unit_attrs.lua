local make_class = require('make_class')
local utils = require('utils')

local class = make_class('UnitAttrs')

function class.new(strength, dexterity)
    local self = {
        strength = utils.require_not_nil(strength, 'strength'),
        dexterity = utils.require_not_nil(dexterity, 'dexterity')
    }
    return setmetatable(self, class)
end

function class:max_hp()
    return self.strength
end

function class:inc_strength()
    if self.strength < 20 then
        self.strength = self.strength + 1
    end
end

function class:inc_dexterity()
    if self.dexterity < 20 then
        self.dexterity = self.dexterity + 1
    end
end

function class:has_max_strength()
    return self.strength >= 20
end

function class:has_max_dexterity()
    return self.dexterity >= 20
end

return class
