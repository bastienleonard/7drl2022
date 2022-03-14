local class = {}
class.__index = class

local function init(self, options)
    self.width = options.width
    self.height = options.height
    self.tiles = {}

    for _ = 1, self.width * self.height do
        table.insert(self.tiles, options.make_tile())
    end
end

function class.new(options)
    local self = {}
    init(self, options)
    return setmetatable(self, class)
end

function class:get(x, y)
    if not y then
        y = x.y
        x = x.x
    end

    if x < 0 or x >= self.width or y < 0 or y >= self.height then
        error(
            string.format(
                '(%s,%s) it out of boundaries (%sx%s)',
                x,
                y,
                self.width,
                self.height
            )
        )
    end

    return self.tiles[x + y * self.width + 1]
end

function class:get_or_nil(x, y)
    if not y then
        y = x.y
        x = x.x
    end

    if not self:contains(x, y) then
        return nil
    end

    return self:get(x, y)
end

function class:contains(x, y)
    if not y then
        y = x.y
        x = x.x
    end

    return x >= 0 and x < self.width and y >= 0 and y < self.height
end

return class
