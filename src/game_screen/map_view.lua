local BaseView = require('ui.base_view')
local colors = require('colors')
local make_class = require('make_class')
local utils = require('utils')

local class = make_class(
    'MapView',
    {
        _parent = BaseView
    }
)

local function tile_rendering_info(tile, unit)
    local char
    local color = nil
    local alpha = 0.2

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

function class._init(self, options)
    class.parent._init(self, options)
end

function class:measure(options)
    local map = globals.screens:current().map
    self:set_measured(options.max_width, options.max_height)
end

function class:draw(x, y)
    class.parent.draw(self, x, y)
    local map = globals.screens:current().map
    local terminal = globals.terminal
    local hero = globals.screens:current().hero
    local k = math.floor(self.measured_width / 2)
    local map_x_start = math.max(
        0,
        hero.position.x - k
    )
    local map_x_end = math.min(
        map.width - 1,
        hero.position.x + k
    )
    local map_y_start = math.max(
        0,
        hero.position.y - k
    )
    local map_y_end = math.min(
        map.height - 1,
        hero.position.y + k
    )

    for map_x = map_x_start, map_x_end do
        for map_y = map_y_start, map_y_end do
            local terminal_x = x
                + map_x
                - hero.position.x
                + math.floor(self.measured_width / 2)
            local terminal_y = y
                + map_y
                - hero.position.y
               + math.floor(self.measured_height / 2)

            local tile = map:get(map_x, map_y)

            if tile.fov_status ~= tile.FovStatus.UNEXPLORED then
                local unit = globals.screens:current():unit_at(map_x, map_y)
                local char, color, alpha = tile_rendering_info(tile, unit)

                if self:rect():contains(terminal_x, terminal_y) then
                    self:draw_text(
                        char,
                        terminal_x,
                        terminal_y,
                        {
                            text_color = color,
                            alpha = alpha
                        }
                    )
                end
            end
        end
    end
end

return class
