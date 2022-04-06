local utf8 = require('utf8')

local Rect = require('rect')

local DRAW_BOUNDS = false

local class = {}

local function rect(self)
    return Rect.new(
        self._bound_check_x,
        self._bound_check_y,
        self.measured_width,
        self.measured_height
    )
end

local function draw_text(text, x, y, options)
    options = options or {}
    local max_width = options.max_width or globals.terminal.width - x

    for i = 1, utf8.len(text) do
        if i > max_width then
            break
        end

        local char_start_offset = utf8.offset(text, i)
        local next_char_start_offset = utf8.offset(text, i + 1)
        local char = text:sub(
            char_start_offset,
            next_char_start_offset - 1
        )
        globals.terminal:draw_cell(char, x, y, { color = options.text_color })
        x = x + 1
    end
end

function class._init(self, options)
    assert(options)
end

function class:measure(options)
    error(string.format("View class must implement measure(): %s", self))
end

function class:draw(x, y)
    assert(x >= 0)
    assert(y >= 0)
    assert(self:is_measured())
    self._bound_check_x = x
    self._bound_check_y = y

    if DRAW_BOUNDS then
        local terminal = globals.terminal
        love.graphics.setColor(0, 1, 1, 0.1)
        love.graphics.rectangle(
            'fill',
            x * terminal.cell_width,
            y * terminal.cell_height,
            self.measured_width * terminal.cell_width,
            self.measured_height * terminal.cell_height
        )
    end
end

function class:is_measured()
    return self.measured_width and self.measured_height
end

function class:set_measured(width, height)
    if width < 0 then
        error(string.format('%s has negative %s width', self, width))
    end

    if height < 0 then
        error(string.format('%s has negative %s width', self, height))
    end

    self.measured_width = width
    self.measured_height = height
end

function class:draw_text(text, x, y, options)
    options = options or {}
    assert(x >= 0)
    assert(y >= 0)
    local text_length = options.max_width or utf8.len(text)

    if text_length == 0 then
        return
    end

    for _, coords in ipairs({
            { x, y },
            { x + text_length - 1, y }
    }) do
        local x = coords[1]
        local y = coords[2]

        if not rect(self):contains(x, y) then
            error(
                string.format(
                    '%s: attempted to draw at (%s,%s)'
                    .. ', out of view boundaries %s',
                    self,
                    x,
                    y,
                    rect(self)
                )
            )
        end
    end

    draw_text(text, x, y, options)
end

return class