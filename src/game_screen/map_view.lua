local BaseView = require('ui.base_view')
local colors = require('colors')
local utils = require('utils')

local parent = BaseView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function tile_rendering_info(tile, unit)
    local char
    local color = nil
    local alpha = 0.3

    if tile.fov_status == tile.FovStatus.IN_SIGHT then
        alpha = 1.0
    end

    if unit and tile.fov_status == tile.FovStatus.IN_SIGHT then
        if unit:is_hero() then
            char = '@'
            color = colors.BLUE
        elseif unit.kind == unit.Kind.RAT then
            char = 'r'
            color = colors.PINK
        elseif unit.kind == unit.Kind.KNIGHT then
            char = 'k'
            color = colors.ORANGE
        elseif unit.kind == unit.Kind.DEMON then
            char = 'd'
            color = colors.RED
        end
    else
        if tile.kind == tile.Kind.STAIRS then
            char = '%'
            color = colors.YELLOW
        elseif tile.kind == tile.Kind.WALL then
            char = '#'
            color = colors.LIGHT_GRAY
        elseif tile.kind == tile.Kind.NOTHING then
            if #tile.items > 0 then
                char = '?'
                color = colors.YELLOW
            else
                char = '.'
                color = colors.DARK_GRAY
            end
        else
            error(
                string.format(
                    'Unhandled tile kind %s',
                    tile.kind
                )
            )
        end
    end

    return char, color, alpha
end

function class.new(options)
    local self = {}
    parent._init(self, options)
    return setmetatable(self, class)
end

function class:__tostring()
    return 'MapView'
end

function class:measure(options)
    local map = globals.screens:current().map
    self:set_measured(options.max_width, options.max_height)
end

function class:draw(x, y)
    parent.draw(self, x, y)
    local map = globals.screens:current().map
    local terminal = globals.terminal

    for map_x = 0, math.min(map.width - 1, x + self.measured_width - 1) do
        for map_y = 0, math.min(map.height - 1, x + self.measured_height - 1) do
            local tile = map:get(map_x, map_y)

            if tile.fov_status ~= tile.FovStatus.UNEXPLORED then
                local unit = globals.screens:current():unit_at(map_x, map_y)
                local char, color, alpha = tile_rendering_info(tile, unit)
                local hero = globals.screens:current().hero
                local transformed_x = x
                    + map_x
                    - hero.position.x
                    + utils.round(self.measured_width / 2)
                local transformed_y = y
                    + map_y
                    - hero.position.y
                    + utils.round(self.measured_height / 2)

                if transformed_x >= x
                    and transformed_x < x + self.measured_width
                    and transformed_y >= y
                    and transformed_y < y + self.measured_height then
                    terminal:draw_cell(
                        char,
                        transformed_x,
                        transformed_y,
                        {
                            color = color,
                            alpha = alpha
                        }
                    )
                end
            end
        end
    end
end

return class
