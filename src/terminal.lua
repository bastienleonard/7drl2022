local utf8 = require('utf8')

local colors = require('colors')
local Rect = require('rect')
local table_utils = require('table_utils')
local ui_scaled = require('ui_scaled')

local class = {}
class.__index = class

local FONT_SOURCE_CODE_PRO = 'assets/fonts/source_code_pro/static/SourceCodePro-Regular.ttf'

local function init(self, font_size)
    self.font_size = font_size
    self.background_color = colors.BLACK
    self.text_color = colors.WHITE
    self.font = love.graphics.newFont(
        FONT_SOURCE_CODE_PRO,
        self.font_size
    )
    self.font_width = self.font:getWidth('.')
    self.font_height = self.font:getHeight()
    print(
        string.format(
            'Font size: %s (%sx%s pixels)',
            self.font_size,
            self.font_width,
            self.font_height
        )
    )
    self.cell_width = self.font_width
    self.cell_height = self.font_height
    assert(self.font_width <= self.cell_width)
    assert(self.font_height <= self.cell_height)
    self.font_x_offset = math.floor((self.cell_width - self.font_width) / 2)
    self.font_y_offset = math.floor((self.cell_height - self.font_height) /2)
    print(
        string.format(
            'Font offsets: (%s,%s)', self.font_x_offset, self.font_y_offset
        )
    )
    assert(self.font_x_offset >= 0)
    assert(self.font_y_offset >= 0)
    self.width = math.floor(love.graphics.getWidth() / self.cell_width)
    self.height = math.floor(love.graphics.getHeight() / self.cell_height)
    self.rect = Rect.new(0, 0, self.width, self.height)
    self.x_offset = math.floor(
        (love.graphics.getWidth() - self.width * self.cell_width) / 2
    )
    self.y_offset = math.floor(
        (love.graphics.getHeight() - self.height * self.cell_height) / 2
    )
    print(
        string.format(
            'Terminal size: %sx%s, cell size: %sx%s pixels, offset: (%s,%s)',
            self.width,
            self.height,
            self.cell_width,
            self.cell_height,
            self.x_offset,
            self.y_offset
        )
    )
end

function class.new(font_size)
    font_size = font_size or ui_scaled(15)
    local self = {}
    init(self, font_size)
    return setmetatable(self, class)
end

function class:draw_cell(char, x, y, options)
    options = options or {}
    local text_color = options.text_color or self.text_color
    local alpha = options.alpha or 1

    if #text_color == 3 then
        table.insert(text_color, alpha)
    elseif #text_color == 4 then
        text_color[4] = alpha
    else
        error('Unreachable')
    end

    if not self.rect:contains(x, y) then
        error(
            string.format(
                '(%s,%s) is not within terminal bounds %s',
                x,
                y,
                self.rect
            )
        )
    end

    assert(utf8.len(char) == 1)
    local background_color = table_utils.dup(
        options.background_color or self.background_color
    )
    table.insert(background_color, alpha)
    love.graphics.setColor(unpack(background_color))
    love.graphics.rectangle(
        'fill',
        self.x_offset + x * self.cell_width,
        self.y_offset + y * self.cell_height,
        self.cell_width,
        self.cell_height
    )
    love.graphics.setColor(unpack(text_color))
    love.graphics.print(
        char,
        self.font,
        self.x_offset + x * self.cell_width + self.font_x_offset,
        self.y_offset + y * self.cell_height + self.font_y_offset
    )
end

function class:draw_grid()
    love.graphics.setColor(unpack(colors.DARK_GRAY))

    -- Vertical lines
    for x = 0, self.width do
        love.graphics.line(
            self.x_offset + x * self.cell_width,
            self.y_offset,
            self.x_offset + x * self.cell_width,
            self.y_offset + self.height * self.cell_height
        )
    end

    -- Horizontal lines
    for y = 0, self.height do
        love.graphics.line(
            self.x_offset,
            self.y_offset + y * self.cell_height,
            self.x_offset + self.width * self.cell_width,
            self.y_offset + y * self.cell_height
        )
    end
end

return class
