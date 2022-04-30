local CellKind = require('cell_kind')
local fonts_cache = require('fonts_cache')
local make_class = require('make_class')
local Text = require('text')
local ui_scaled = require('ui_scaled')
local utils = require('utils')

local image = love.graphics.newImage(
    'assets/tilesets/kenney_1bit/Tilesheet/monochrome-transparent_packed.png'
)
local image_cell_width = 16
local image_cell_height = 16
local ORIENTATION_90 = math.pi / 2
local ORIENTATION_180 = math.pi
local ORIENTATION_270 = 3 / 2 * math.pi

local class = make_class('Kenney1Bit')

local function load_font_for_cell_size(path, max_width, max_height)
    local lowest = 1
    local highest = ui_scaled(1000)

    while true do
        assert(highest - lowest > 1)
        local size = math.floor((lowest + highest) / 2)
        local font = fonts_cache.get(path, size)

        -- Assume all characters have the same width
        if font:getWidth('.') > max_width or font:getHeight() > max_height then
            highest = math.max(1, size - 1)
        else
            lowest = size
        end

        if lowest == highest or highest == lowest + 1 then
            return font
        end
    end

    error('Unreachable')
end

local function make_fallback_font(self)
    assert(self)
    local font = load_font_for_cell_size(
        'assets/fonts/kenney_fonts/Fonts/Kenney Future Narrow.ttf',
        self.cell_width,
        self.cell_height
    )
    font:setFallbacks(
        load_font_for_cell_size(
            'assets/fonts/source_code_pro/static/SourceCodePro-Regular.ttf',
            self.cell_width,
            self.cell_height
        )
    )
    return font
end

local function draw_character_fallback(self, char, x, y)
    assert(char)
    assert(x)
    assert(y)

    if Text.is_instance(char) then
        char = char.lua_string
    end

    local terminal = globals.terminal
    local font = self.fallback_font
    local cell_x_offset = math.max(
        0,
        utils.round(
            (self.cell_width - font:getWidth(char)) / 2
        )
    )
    local cell_y_offset = math.max(
        0,
        utils.round(
            (self.cell_height - font:getHeight()) / 2
        )
    )
    love.graphics.print(
        char,
        font,
        terminal.x_offset + x * self.cell_width + cell_x_offset,
        terminal.y_offset + y * self.cell_height + cell_y_offset
    )
end

local function character_rendering_data(char)
    local orientation = 0
    local tileset_x
    local tileset_y

    if type(char) ~= 'string' then
        assert(Text.is_instance(char))
        char = char.lua_string
    end

    if char == ' ' then
        return nil
    end

    char = char:lower()

    if char == '│' then
        tileset_x = 14
        tileset_y = 3
    elseif char == '─' then
        tileset_x = 14
        tileset_y = 3
        orientation = ORIENTATION_90
    elseif char == '╭' then
        tileset_x = 15
        tileset_y = 3
    elseif char == '╮' then
        tileset_x = 15
        tileset_y = 3
        orientation = ORIENTATION_90
    elseif char == '╰' then
        tileset_x = 15
        tileset_y = 3
        orientation = ORIENTATION_270
    elseif char == '╯' then
        tileset_x = 15
        tileset_y = 3
        orientation = ORIENTATION_180
    elseif char == '╴' then
        tileset_x = 13
        tileset_y = 3
        orientation = ORIENTATION_90
    elseif char == '╶' then
        tileset_x = 13
        tileset_y = 3
        orientation = ORIENTATION_270
    elseif char == '▲' then
        tileset_x = 23
        tileset_y = 20
    elseif char == '▼' then
        tileset_x = 23
        tileset_y = 20
        orientation = ORIENTATION_180
    end

    return tileset_x, tileset_y, orientation
end

local function rendering_data(cell_kind)
    local tileset_x
    local tileset_y
    local orientation = 0

    if cell_kind:is(CellKind.Character) then
        tileset_x, tileset_y, orientation = character_rendering_data(
            cell_kind.char
        )

        if not tileset_x or not tileset_y then
            return cell_kind.char
        end
    elseif cell_kind:is(CellKind.Nothing) then
        tileset_x = 16
        tileset_y = 0
    elseif cell_kind:is(CellKind.Wall) then
        tileset_x = 0
        tileset_y = 13
    elseif cell_kind:is(CellKind.Stairs) then
        tileset_x = 3
        tileset_y = 6
    elseif cell_kind:is(CellKind.Items) then
        tileset_x = 8
        tileset_y = 6
    elseif cell_kind:is(CellKind.Hero) then
        tileset_x = 27
        tileset_y = 0
    elseif cell_kind:is(CellKind.Rat) then
        tileset_x = 31
        tileset_y = 8
    elseif cell_kind:is(CellKind.Knight) then
        tileset_x = 28
        tileset_y = 0
    elseif cell_kind:is(CellKind.Demon) then
        tileset_x = 30
        tileset_y = 8
    end

    if not tileset_x or not tileset_y then
        print(
            string.format(
                'Warning: no tileset coordinates for cell kind %s',
                cell_kind
            )
        )
        tileset_x = 37
        tileset_y = 21
    end

    assert(tileset_x)
    assert(tileset_y)
    return tileset_x, tileset_y, orientation
end

function class._init(self, size)
    self.scaling = 2 ^ (size + math.floor(math.log(ui_scaled(1), 2)))
    print(string.format('Tile scaling: %s', self.scaling))
    self.cell_width = image_cell_width * self.scaling
    self.cell_height = image_cell_height * self.scaling
    self.fallback_font = make_fallback_font(self)
end

function class:draw_cell(cell_kind, x, y, options)
    assert(cell_kind)

    local tileset_x, tileset_y, orientation = rendering_data(cell_kind)

    if not tileset_x then
        return
    end

    if type(tileset_x) == 'string' or Text.is_instance(tileset_x) then
        draw_character_fallback(self, tileset_x, x, y)
        return
    end

    if not tileset_y then
        return
    end

    if orientation ~= 0 then
        if orientation == ORIENTATION_90 then
            x = x + 1
        elseif orientation == ORIENTATION_180 then
            x = x + 1
            y = y + 1
        elseif orientation == ORIENTATION_270 then
            y = y + 1
        else
            error(string.format('Unhandled orientation %s', orientation))
        end
    end

    local terminal = globals.terminal
    love.graphics.draw(
        image,
        love.graphics.newQuad(
            tileset_x * image_cell_width,
            tileset_y * image_cell_height,
            image_cell_width,
            image_cell_height,
            image
        ),
        terminal.x_offset + x * self.cell_width,
        terminal.y_offset + y * self.cell_height,
        orientation,
        self.scaling,
        self.scaling
    )
end

return class
