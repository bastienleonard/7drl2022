local BaseView = require('ui.base_view')
local make_class = require('make_class')
local TextView = require('ui.text_view')
local utils = require('utils')

local class = make_class(
    'BorderView',
    {
        _parent = BaseView
    }
)

function class._init(self, options)
    class.parent._init(self, options)
    self.title = utils.require_key(options, 'title')

    if options.add_child_padding == nil then
        options.add_child_padding = true
    end

    self.add_child_padding = options.add_child_padding
    self.children = utils.require_key(options, 'children')
    assert(#self.children == 1)
end

function class:measure(options)
    local width = options.width
    local height = options.height

    if width > 4 and height > 2 then
        local child = self.children[1]
        local x_offset

        if self.add_child_padding then
            x_offset = 4
        else
            x_offset = 2
        end

        child:measure({
                max_width = width - x_offset,
                max_height = height - 2
        })
    else
        self.children = {}
    end

    self:set_measured(width, height)
end

function class:draw(x, y)
    class.parent.draw(self, x, y)

    if self.measured_width < 3 or self.measured_height < 3 then
        return
    end

    local terminal = globals.terminal
    self:draw_text('╭', x, y)
    self:draw_text('╮', x + self.measured_width - 1, y)
    self:draw_text('╰', x, y + self.measured_height - 1)
    self:draw_text(
        '╯',
        x + self.measured_width - 1,
        y + self.measured_height - 1
    )

    for x = x + 1, x + self.measured_width - 2 do
        self:draw_text('─', x, y)
    end

    self.title = '╴' .. self.title .. '╶'
    self:draw_text(
        self.title,
        x + 1,
        y,
        { max_width = self.measured_width - 3 }
    )

    for x = x + 1, x + self.measured_width - 2 do
        self:draw_text('─', x, y + self.measured_height - 1)
    end

    for y = y + 1, y + self.measured_height - 2 do
        self:draw_text('│', x, y)
    end

    for y = y + 1, y + self.measured_height - 2 do
        self:draw_text('│', x + self.measured_width - 1, y)
    end

    local child = self.children[1]

    if child then
        local x_offset

        if self.add_child_padding then
            x_offset = 2
        else
            x_offset = 1
        end

        self.children[1]:draw(x + x_offset, y + 1)
    end
end

return class
