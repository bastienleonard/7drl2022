local enum = require('enum')

local PlayerInput = enum(
    'REST',
    'MOVE_LEFT',
    'MOVE_RIGHT',
    'MOVE_UP',
    'MOVE_DOWN',
    'MOVE_LEFT_AND_UP',
    'MOVE_LEFT_AND_DOWN',
    'MOVE_RIGHT_AND_UP',
    'MOVE_RIGHT_AND_DOWN',
    'ACTIVATE'
)

PlayerInput.from_scancode = function(scancode)
    assert(scancode)
    local input = nil

    if scancode == '.' then
        input = PlayerInput.REST
    elseif scancode == 'h' then
        input = PlayerInput.MOVE_LEFT
    elseif scancode == 'l' then
        input = PlayerInput.MOVE_RIGHT
    elseif scancode == 'k' then
        input = PlayerInput.MOVE_UP
    elseif scancode == 'j' then
        input = PlayerInput.MOVE_DOWN
    elseif scancode == 'y' then
        input = PlayerInput.MOVE_LEFT_AND_UP
    elseif scancode == 'b' then
        input = PlayerInput.MOVE_LEFT_AND_DOWN
    elseif scancode == 'u' then
        input = PlayerInput.MOVE_RIGHT_AND_UP
    elseif scancode == 'n' then
        input = PlayerInput.MOVE_RIGHT_AND_DOWN
    elseif scancode == 'left' then
        input = PlayerInput.MOVE_LEFT
    elseif scancode == 'right' then
        input = PlayerInput.MOVE_RIGHT
    elseif scancode == 'up' then
        input = PlayerInput.MOVE_UP
    elseif scancode == 'down' then
        input = PlayerInput.MOVE_DOWN
    elseif scancode == 'return' or scancode == 'space' then
        input = PlayerInput.ACTIVATE
    end

    return input
end

return PlayerInput
