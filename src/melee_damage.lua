local MeleeDamageType = require('melee_damage_type')
local random = require('random')

local module = {}

local function roll_for_thrusting(strength)
    local s = strength
    local d = random.roll
    local result

    if s == 1 or s == 2 then
        result = d() - 6
    end

    if s == 3 or s == 4 then
        result = d() - 5
    end

    if s == 5 or s == 6 then
        result = d() - 4
    end

    if s == 7 or s == 8 then
        result = d() - 3
    end

    if s == 9 or s == 10 then
        result = d() - 2
    end

    if s == 11 or s == 12 then
        result = d() - 1
    end

    if s == 13 or s == 14 then
        result = d()
    end

    if s == 15 or s == 16 then
        result = d() + 1
    end

    if s == 17 or s == 18 then
        result = d() + 2
    end

    if s == 19 or s == 20 then
        result = d() + d() - 1
    end

    if not result then
        error(string.format('Unhandled strength %s', s))
    end

    return result
end

local function roll_for_swinging(strength)
    local s = strength
    local d = random.roll
    local result

    if s == 1 or s == 2 then
        return d() - 5
    end

    if s == 3 or s == 4 then
        return d() - 4
    end

    if s == 5 or s == 6 then
        return d() - 3
    end

    if s == 7 or s == 8 then
        return d() - 2
    end

    if s == 9 then
        return d() -1
    end

    if s == 10 then
        return d()
    end

    if s == 11 then
        return d() + 1
    end

    if s == 12 then
        return d() + 2
    end

    if s == 13 then
        return d() + d() - 1
    end

    if s == 14 then
        return d() + d()
    end

    if s == 15 then
        return d() + d() + 1
    end

    if s == 16 then
        return d() + d() + 2
    end

    if s == 17 then
        return d() + d() + d() - 1
    end

    if s == 18 then
        return d() + d() + d()
    end

    if s == 19 then
        return d() + d() + d() + 1
    end

    if s == 20 then
        return d() + d() + d() + 2
    end

    if not result then
        error(string.format('Unhandled strength %s', s))
    end

    return result
end

function module.roll_for_melee_damage_type(melee_damage_type, strength)
    assert(melee_damage_type)
    assert(strength)

    if melee_damage_type == MeleeDamageType.THRUSTING then
        return roll_for_thrusting(strength)
    elseif melee_damage_type == MeleeDamageType.SWINGING then
        return roll_for_swinging(strength)
    else
        error(
            string.format(
                'Unhandled melee damage type %s',
                melee_damage_type
            )
        )
    end
end

return module
