local enum = require('enum')

local class = {
    Kind = enum('NOTHING', 'WALL', 'STAIRS'),
    FovStatus = enum('UNEXPLORED', 'EXPLORED', 'IN_SIGHT')
}
class.__index = class

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
