local enum = require('enum')
local make_class = require('make_class')

local class = make_class('Tile')
class.Kind = enum('NOTHING', 'WALL', 'STAIRS')
class.FovStatus = enum('UNEXPLORED', 'EXPLORED', 'IN_SIGHT')

function class._init(self, kind)
    assert(kind)
    self.kind = kind
    self.fov_status = class.FovStatus.UNEXPLORED
    self.items = {}
end

function class:blocks_sight()
    if self.kind == self.Kind.WALL then
        return true
    end

    return false
end

return class
