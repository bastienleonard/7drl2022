local enum = require('enum')
local Vec2 = require('vec2')

local the_enum = enum(
    'LEFT',
    'RIGHT',
    'UP',
    'DOWN',
    'LEFT_AND_UP',
    'LEFT_AND_DOWN',
    'RIGHT_AND_UP',
    'RIGHT_AND_DOWN'
)

function the_enum:as_vec()
    local result = Vec2[tostring(self)]
    assert(result)
    return result
end

return the_enum
