local BaseView = require('ui.base_view')
local enum = require('enum')
local make_class = require('make_class')
local utils = require('utils')

local class = make_class(
    'StackView',
    {
        _parent = BaseView
    }
)
class.Orientation = enum('HORIZONTAL', 'VERTICAL')

function class._init(self, options)
    class.parent._init(self, options)
    self.orientation = utils.require_key(options, 'orientation')
    self.children = utils.require_key(options, 'children')
end

function class:measure(options)
    local available_width = options.width or options.max_width
    local available_height = options.height or options.max_height

    if available_width then
        assert(available_width >= 0)
    end

    if available_height then
        assert(available_height >= 0)
    end

    local original_available_width = available_width
    local original_available_height = available_height
    local width = 0
    local height = 0

    for _, child in ipairs(self.children) do
        local child_options = {}

        if available_width then
            child_options.max_width = available_width
        end

        if available_height then
            child_options.max_height = available_height
        end

        child:measure(child_options)

        if self.orientation == class.Orientation.HORIZONTAL then
            width = width + child.measured_width

            if child.measured_height > height then
                height = child.measured_height
            end

            if available_width then
                available_width = available_width - child.measured_width
                assert(available_width >= 0)
            end
        elseif self.orientation == class.Orientation.VERTICAL then
            if child.measured_width > width then
                width = child.measured_width
            end

            height = height + child.measured_height

            if available_height then
                available_height = available_height - child.measured_height
                assert(available_height >= 0)
            end
        else
            error('Unreachable')
        end
    end

    if original_available_width then
        assert(width <= original_available_width)
    end

    if original_available_height then
        assert(height <= original_available_height)
    end

    if options.width then
        width = options.width
    end

    if options.height then
        height = options.height
    end

    self:set_measured(width, height)
end

function class:draw(x, y)
    class.parent.draw(self, x, y)

    for _, child in ipairs(self.children) do
        child:draw(x, y)

        if self.orientation == class.Orientation.HORIZONTAL then
            x = x + child.measured_width
        elseif self.orientation == class.Orientation.VERTICAL then
            y = y + child.measured_height
        else
            error('Unreachable')
        end
    end
end

return class
