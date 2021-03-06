local array_utils = require('array_utils')

local module = {}

local colors = {
    BLACK = { 0, 0, 0 },
    DARK_BLUE = { 29, 43, 83 },
    DARK_PURPLE = { 126, 37, 83 },
    DARK_GREEN = { 0, 135, 81 },
    BROWN = { 171, 82, 54 },
    DARK_GRAY = { 95, 87, 79 },
    LIGHT_GRAY = { 194, 195, 199 },
    WHITE = { 255, 241, 232 },
    RED = { 255, 0, 77 },
    ORANGE = { 255, 163, 0 },
    YELLOW = { 255, 236, 39 },
    GREEN = { 0, 228, 54 },
    BLUE = { 41, 173, 255 },
    LAVENDER = { 131, 118, 156 },
    PINK = { 255, 119, 168 },
    LIGHT_PEACH = { 255, 204, 170 }
}
module.ALL = {}

for name, components in pairs(colors) do
    local r = components[1]
    local g = components[2]
    local b = components[3]
    local color = array_utils.map(
        { r, g, b },
        function(n)
            return n / 255
        end
    )
    color = setmetatable(
        color,
        { __tostring = function(self) return name end }
    )
    module[name] = color
    table.insert(module.ALL, color)
end

return module
