local colors = require('colors')
local make_class = require('make_class')
local Rect = require('rect')
local table_utils = require('table_utils')
local Text = require('text')
local ui_scaled = require('ui_scaled')
local utils = require('utils')

local class = make_class('Terminal')

function class._init(self, tileset)
    assert(tileset)
    self.tileset = tileset
    self.background_color = colors.BLACK
    self.text_color = colors.WHITE
    self.width = math.floor(love.graphics.getWidth() / self.tileset.cell_width)
    self.height = math.floor(
        love.graphics.getHeight() / self.tileset.cell_height
    )
    self.rect = Rect.new(0, 0, self.width, self.height)
    self.x_offset = math.floor(
        (love.graphics.getWidth() - self.width * self.tileset.cell_width) / 2
    )
    self.y_offset = math.floor(
        (love.graphics.getHeight() - self.height * self.tileset.cell_height) / 2
    )
    print(
        string.format(
            'Terminal size: %sx%s, cell size: %sx%s pixels, offsets: (%s,%s)',
            self.width,
            self.height,
            self:cell_width(),
            self:cell_height(),
            self.x_offset,
            self.y_offset
        )
    )
    assert(utils.is_integer(self.width))
    assert(utils.is_integer(self.height))
    assert(utils.is_integer(self:cell_width()))
    assert(utils.is_integer(self:cell_height()))
    assert(utils.is_integer(self.x_offset))
    assert(utils.is_integer(self.y_offset))
end

function class:cell_width()
    return self.tileset.cell_width
end

function class:cell_height()
    return self.tileset.cell_height
end

function class:draw_cell(cell_kind, x, y, options)
    options = options or {}
    local text_color = table_utils.dup(options.text_color or self.text_color)
    local alpha = options.alpha or 1

    if #text_color == 3 then
        table.insert(text_color, alpha)
    elseif #text_color == 4 then
        text_color[4] = alpha
    else
        error('Unreachable')
    end

    if not options.allow_drawing_out_of_bounds
        and not self.rect:contains(x, y) then
        error(
            string.format(
                '(%s,%s) is not within terminal bounds %s',
                x,
                y,
                self.rect
            )
        )
    end

    local background_color = table_utils.dup(
        options.background_color or self.background_color
    )
    table.insert(background_color, alpha)
    love.graphics.setColor(unpack(background_color))
    love.graphics.rectangle(
        'fill',
        self.x_offset + x * self:cell_width(),
        self.y_offset + y * self:cell_height(),
        self:cell_width(),
        self:cell_height()
    )
    love.graphics.setColor(unpack(text_color))
    self.tileset:draw_cell(cell_kind, x, y, options)
end

function class:draw_grid()
    love.graphics.setColor(unpack(colors.DARK_GRAY))

    -- Vertical lines
    for x = 0, self.width do
        love.graphics.line(
            self.x_offset + x * self:cell_width(),
            self.y_offset,
            self.x_offset + x * self:cell_width(),
            self.y_offset + self.height * self:cell_height()
        )
    end

    -- Horizontal lines
    for y = 0, self.height do
        love.graphics.line(
            self.x_offset,
            self.y_offset + y * self:cell_height(),
            self.x_offset + self.width * self:cell_width(),
            self.y_offset + y * self:cell_height()
        )
    end
end

return class
