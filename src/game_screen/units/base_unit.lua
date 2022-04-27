local make_class = require('make_class')
local MeleeDamageType = require('melee_damage_type')
local DamageType = require('damage_type')
local UnitAttrs = require('game_screen.units.unit_attrs')
local UnitKind = require('game_screen.units.unit_kind')
local weapons = require('weapons')

local class = make_class('BaseUnit')
class.Kind = UnitKind
class.Attrs = UnitAttrs

function class._init(self, kind, position, attrs)
    self.kind = kind
    assert(self.kind)
    self.position = position
    assert(self.position)
    self.base_attrs = attrs
    assert(self.base_attrs)
    self.hp = self:max_hp()
    self._equipped_weapon = nil
    self.seen = false
end

function class:is_hero()
    return self.kind == class.Kind.HERO
end

function class:max_hp()
    return self:strength()
end

function class:strength()
    return self.base_attrs.strength
end

function class:dexterity()
    return self.base_attrs.dexterity
end

function class:has_max_strength()
    return self.base_attrs:has_max_strength()
end

function class:has_max_dexterity()
    return self.base_attrs:has_max_dexterity()
end

function class:heal(amount)
    if amount then
        self.hp = math.min(self.hp + amount, self:max_hp())
    else
        self.hp = self:max_hp()
    end
end

function class:equipped_weapon()
    if self._equipped_weapon then
        return self._equipped_weapon
    end

    return weapons.FISTS
end

function class:equip(item)
    self._equipped_weapon = item
end

return class
