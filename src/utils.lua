local array_utils = require('array_utils')
local colors = require('colors')

local module = {}

function module.is_integer(n)
    return math.floor(n) == n
end

function module.round(n)
    return math.floor(n + 0.5)
end

function module.clamp(n, low, high)
    if n < low then
        return low
    end

    if n > high then
        return high
    end

    return n
end

function module.is_power_of_two(n)
    assert(n)
    return module.is_integer(math.log(n, 2))
end

function module.distance(a, b)
    assert(a)
    assert(b)
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end

function module.require_not_nil(x, name)
    if x == nil then
        if name == nil then
            name = '[unspecified]'
        end

        error(string.format('%s cannot be nil', name))
    end

    return x
end

function module.require_key(x, name)
    assert(name)

    if x == nil or x[name] == nil then
        error(string.format('%s cannot be nil', name))
    end

    return x[name]
end

function module.make_to_string(class_name, ...)
    assert(class_name)
    local args = { ... }
    return function(self)
        return string.format(
            '%s<%s>',
            class_name,
            table.concat(
                array_utils.map(
                    args,
                    function(attr)
                        return string.format(
                            '%s=%s',
                            attr,
                            self[attr]
                        )
                    end
                ),
                ' '
            )
        )
    end
end

function module.print_with_shadow(text, font, x, y, text_color, shadow_color)
    assert(text)
    assert(font)
    assert(x)
    assert(y)
    text_color = text_color or colors.WHITE
    shadow_color = shadow_color or colors.BLACK
    local offset = 1
    love.graphics.setColor(unpack(shadow_color))
    love.graphics.print(text, font, x + offset, y + offset)
    love.graphics.setColor(unpack(text_color))
    love.graphics.print(text, font, x, y)
end

return module
