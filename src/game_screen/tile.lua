local enum = require('enum')
local make_class = require('make_class')

local class = make_class('Tile')
class.Kind = enum('NOTHING', 'WALL', 'STAIRS')
class.FovStatus = enum('UNEXPLORED', 'EXPLORED', 'IN_SIGHT')

function class.new(kind)
    assert(kind)
    local self = {
        kind = kind,
        fov_status = class.FovStatus.UNEXPLORED,
        items = {}
    }
    return setmetatable(self, class)
end

function class:blocks_sight()
    if self.kind == self.Kind.WALL then
        return true
    end

    return false
end

return class
