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
    local width = options.width
    local height = options.height

    if width > 4 and height > 2 then
        local child = self.children[1]
        child:measure({
                max_width = width - 4,
                max_height = height - 2
        })
    else
        self.children = {}
    end

    self:set_measured(width, height)
end

function class:draw(x, y)
    parent.draw(self, x, y)

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
        self.children[1]:draw(x + 2, y + 1)
    end
end

return class
