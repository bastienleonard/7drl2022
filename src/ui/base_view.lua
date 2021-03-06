local make_class = require('make_class')
local Rect = require('rect')
local Text = require('text')

local DRAW_BOUNDS = false

local class = make_class('BaseView')
local view_states = {}

local function draw_text(text, x, y, options)
    options = options or {}
    local max_width = options.max_width or globals.terminal.width - x

    for i = 1, text:length() do
        if i > max_width then
            break
        end

        local char = text:text_at(i)
        globals.terminal:draw_cell(char, x, y, options)
        x = x + 1
    end
end

function class.state_from_id(id)
    assert(id)

    if view_states[id] == nil then
        view_states[id] = {}
    end

    return view_states[id]
end

function class._init(self, options)
    assert(options)
    self.id = options.id
    self.background_color = options.background_color
end

function class:measure(options)
    error(string.format("View class must implement measure(): %s", self))
end

function class:draw(x, y)
    assert(x >= 0)
    assert(y >= 0)
    assert(self:is_measured())
    self.x = x
    self.y = y

    if self.background_color then
        local options = {
            background_color = self.background_color
        }

        if self.allow_drawing_out_of_bounds then
            options.allow_drawing_out_of_bounds = true
        end

        for x = self.x, self.x + self.measured_width - 1 do
            for y = self.y, self.y + self.measured_height - 1 do
                globals.terminal:draw_cell(
                    ' ',
                    x,
                    y,
                    options
                )
            end
        end
    end

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

function class:rect()
    return Rect.new(
        self.x,
        self.y,
        self.measured_width,
        self.measured_height
    )
end

function class:draw_text(text, x, y, options)
    options = options or {}
    assert(x >= 0)
    assert(y >= 0)

    if type(text) == 'string' then
        text = Text.new(text)
    end

    assert(text:is(Text))
    local text_length = options.max_width or text:length()

    if text_length == 0 then
        return
    end

    for _, coords in ipairs({
            { x, y },
            { x + text_length - 1, y }
    }) do
        local x = coords[1]
        local y = coords[2]

        if not self:rect():contains(x, y) then
            error(
                string.format(
                    '%s: attempted to draw at (%s,%s)'
                    .. ', out of view boundaries %s',
                    self,
                    x,
                    y,
                    self:rect()
                )
            )
        end
    end

    if not options.background_color then
        options.background_color = self.background_color
    end

    if self.allow_drawing_out_of_bounds then
        options.allow_drawing_out_of_bounds = true
    end

    draw_text(text, x, y, options)
end

function class:get_state()
    assert(self.id)
    return class.state_from_id(self.id)
end

function class:on_click(x, y)
    if self.children then
        for _, child in ipairs(self.children) do
            if child.x and child.y and child:rect():contains(x, y) then
                child:on_click(x, y)
                break
            end
        end
    end
end

function class:allow_drawing_out_of_bounds()
    self._allow_drawing_out_of_bounds = true
end

return class
