local BaseView = require('ui.base_view')
local TextView = require('ui.text_view')
local utils = require('utils')

local parent = BaseView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function init(self, options)
    self.title = utils.require_key(options, 'title')
    self.children = utils.require_key(options, 'children')
    assert(#self.children == 1)
end

function class.new(options)
    local self = {}
    parent._init(self, options)
    init(self, options)
    return setmetatable(self, class)
end

function class:__tostring()
    return 'BorderView'
end

function class:measure(options)
    local child = self.children[1]
    child:measure({
            max_width = options.width - 4,
            max_height = options.height - 2
    })
    self:set_measured(options.width, options.height)
end

function class:draw(x, y)
    parent.draw(self, x, y)
    local terminal = globals.terminal
    terminal:draw_cell('╭', x, y)
    terminal:draw_cell('╮', x + self.measured_width - 1, y)
    terminal:draw_cell('╰', x, y + self.measured_height - 1)
    terminal:draw_cell(
        '╯',
        x + self.measured_width - 1,
        y + self.measured_height - 1
    )

    for x = x + 1, x + self.measured_width - 2 do
        terminal:draw_cell('─', x, y)
    end

    self.title = '╴' .. self.title .. '╶'
    TextView.draw_text(
        self.title,
        x + 1,
        y,
        { max_width = self.measured_width - 3 }
    )

    for x = x + 1, x + self.measured_width - 2 do
        terminal:draw_cell('─', x, y + self.measured_height - 1)
    end

    for y = y + 1, y + self.measured_height - 2 do
        terminal:draw_cell('│', x, y)
    end

    for y = y + 1, y + self.measured_height - 2 do
        terminal:draw_cell('│', x + self.measured_width - 1, y)
    end

    self.children[1]:draw(x + 2, y + 1)
end

return class
