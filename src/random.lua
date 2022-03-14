local table_utils = require('table_utils')

local module = {}

function module.choice(array)
    assert(array)

    if #array == 0 then
        error('Called random.choice() on an empty array')
    end

    return array[love.math.random(1, #array)]
end

function module.shuffle(array)
    assert(array)

    if #array < 2 then
        return
    end

    for i = 1, #array - 1 do
        local j = love.math.random(i, #array)
        array[i], array[j] = array[j], array[i]
    end
end

function module.shuffled(array)
    assert(array)
    local result = table_utils.dup(array)
    module.shuffle(result)
    return result
end

function module.coin_flip()
    return love.math.random(0, 1) == 0
end

function module.roll()
    return love.math.random(1, 6)
end

function module.roll_twice()
    return module.roll() + module.roll()
end

function module.roll_thrice()
    return module.roll() + module.roll() + module.roll()
end

return module
