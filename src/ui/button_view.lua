local utf8 = require('utf8')

local BaseView = require('ui.base_view')
local make_class = require('make_class')
local utils = require('utils')

local class = make_class(
    'ButtonView',
    {
        _parent = BaseView
    }
)

local function init(self, options)
    self.text = utils.require_key(options, 'text')
    self.text_color = options.text_color
    self.on_click = utils.require_key(options, 'on_click')
end

function class.new(options)
    local self = setmetatable({}, class)
    class.parent._init(self, options)
    init(self, options)
    return self
end

function class:measure(options)
    options = options or {}
    local width

    if options.width then
        width = options.width
    else
        width = utf8.len(self.text)

        if options.max_width then
            width = math.min(width, options.max_width)
        end
    end

    local height

    if options.height then
        height = options.height
    else
        height = 1

        if options.max_height then
            height = math.min(height, options.max_height)
        end
    end

    self:set_measured(width, height)
end

function class:draw(x, y)
    class.parent.draw(self, x, y)

    if #self.text > 0
        and self.measured_width > 0
        and self.measured_height > 0 then
        self:draw_text(
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

function class:on_click(x, y)
    self.on_click()
end

return class
