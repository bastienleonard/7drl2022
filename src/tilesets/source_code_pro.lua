local CellKind = require('cell_kind')
local fonts_cache = require('fonts_cache')
local make_class = require('make_class')
local ui_scaled = require('ui_scaled')
local utils = require('utils')

local class = make_class('SourceCodePro')

local FONT_SOURCE_CODE_PRO = 'assets/fonts/source_code_pro/static/SourceCodePro-Regular.ttf'

local function rendering_data(cell_kind)
    local char

    if cell_kind:is(CellKind.Character) then
        char = cell_kind.char

        if type(char) ~= 'string' then
            char = char.lua_string
        end
    elseif cell_kind:is(CellKind.Nothing) then
        char = '.'
    elseif cell_kind:is(CellKind.Wall) then
        char = '#'
    elseif cell_kind:is(CellKind.Stairs) then
        char = '%'
    elseif cell_kind:is(CellKind.Items) then
        char = '?'
    elseif cell_kind:is(CellKind.Hero) then
        char = '@'
    elseif cell_kind:is(CellKind.Rat) then
        char = 'r'
    elseif cell_kind:is(CellKind.Knight) then
        char = 'k'
    elseif cell_kind:is(CellKind.Demon) then
        char = 'd'
    end

    assert(char)
    return char
end

function class._init(self, size)
    assert(size)
    self.font_size = utils.round(ui_scaled(size + 15))
    assert(utils.is_integer(self.font_size))
    self.font = fonts_cache.get(
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
end

function class:draw_cell(cell_kind, x, y, options)
    local char = rendering_data(cell_kind)
    local terminal = globals.terminal
    love.graphics.print(
        char,
        self.font,
        terminal.x_offset + x * self.cell_width,
        terminal.y_offset + y * self.cell_height
    )
end

return class
