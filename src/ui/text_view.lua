local utf8 = require('utf8')

local BaseView = require('ui.base_view')
local utils = require('utils')

local parent = BaseView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function init(self, options)
    self.text = utils.require_key(options, 'text')
    self.text_color = options.text_color
end

function class.draw_text(text, x, y, options)
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

function class.new(options)
    local self = {}
    parent._init(self, options)
    init(self, options)
    return setmetatable(self, class)
end

function class:measure(options)
    options = options or {}
    local width = utf8.len(self.text)
    local height = 1

    if options.max_width then
        width = math.min(width, options.max_width)
    end

    if options.max_height then
        height = math.min(height, options.max_height)
    end

    self:set_measured(width, height)
end

function class:draw(x, y)
    parent.draw(self, x, y)

    if self.measured_height >= 1 then
        class.draw_text(
            self.text,
            x,
            y,
            {
                max_width = self.measured_width,
                text_color = self.text_color
            }
        )
    end
end

return class
