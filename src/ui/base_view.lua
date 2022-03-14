local DRAW_BOUNDS = false

local class = {}

function class._init(self, options)
    assert(options)
end

function class:measure(options)
    error(string.format("View class must implement measure(): %s", self))
end

function class:draw(x, y)
    assert(x)
    assert(y)
    assert(self:is_measured())

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
    self.measured_width = width
    self.measured_height = height
end

return class
