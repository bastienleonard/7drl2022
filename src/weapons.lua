local MeleeDamageType = require('melee_damage_type')
local DamageType = require('damage_type')

local module = {}

module.FISTS = {
    name = 'fists',
    melee_damage_type = MeleeDamageType.THRUSTING,
    modifier = -1,
    damage_type = DamageType.CRUSHING
}
local BLACKJACK = {
    name = 'blackjack',
    melee_damage_type = MeleeDamageType.THRUSTING,
    modifier = 0,
    damage_type = DamageType.CRUSHING
}
local KNIFE = {
    name = 'knife',
    melee_damage_type = MeleeDamageType.SWINGING,
    modifier = -2,
    damage_type = DamageType.CUTTING
}
local SWORD = {
    name = 'sword',
    melee_damage_type = MeleeDamageType.SWINGING,
    modifier = 1,
    damage_type = DamageType.CUTTING
}
local AXE = {
    name = 'axe',
    melee_damage_type = MeleeDamageType.SWINGING,
    modifier = 2,
    damage_type = DamageType.CUTTING
}
local POLEARM = {
    name = 'polearm',
    melee_damage_type = MeleeDamageType.SWINGING,
    modifier = 4,
    damage_type = DamageType.CUTTING
}
local WEAPONS = {
    module.FISTS,
    BLACKJACK,
    KNIFE,
    SWORD,
    AXE,
    POLEARM
}

function module.next_weapon(weapon)
    for i, current in ipairs(WEAPONS) do
        if current == weapon then
            return WEAPONS[i + 1]
        end
    end

    error('Unreachable')
end

function module.has_upgrade(weapon)
    for i, current in ipairs(WEAPONS) do
        if current == weapon then
            return i < #WEAPONS
        end
    end

    error('Unreachable')
end

return module
