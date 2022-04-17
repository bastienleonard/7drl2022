local BaseView = require('ui.base_view')
local utils = require('utils')

local parent = BaseView
local class = setmetatable({}, { __index = parent })
class.__index = class

local SCROLL_STEP = 5

local function init(self, options)
    self.children = utils.require_key(options, 'children')
    assert(#self.children == 1)
    local state = self:get_state()

    if state.scroll_to_last == nil then
        state.scroll_to_last = false
    end

    if state.scrolled_offset == nil then
        state.scrolled_offset = 0
    end
end

local function last_offset(self)
    local child = self.children[1]
    return child.measured_height - self.measured_height
end

function class.scroll_down(id)
    local state = class.state_from_id(id)
    state.scrolled_offset = state.scrolled_offset + SCROLL_STEP
end

function class.scroll_up(id)
    local state = class.state_from_id(id)
    local scrolled_offset = state.scrolled_offset
    scrolled_offset = scrolled_offset - SCROLL_STEP

    if scrolled_offset < 0 then
        scrolled_offset = 0
    end

    state.scrolled_offset = scrolled_offset
end

function class.scroll_to_bottom(id)
    class.state_from_id(id).scroll_to_last = true
end

function class.new(options)
    local self = setmetatable({}, class)
    parent._init(self, options)
    init(self, options)
    return self
end

function class:__tostring()
    return 'ScrollView'
end

function class:measure(options)
    self:set_measured(options.max_width, options.max_height)
    local child = self.children[1]
    child:measure({ max_width = options.max_width })
    local state = self:get_state()

    if state.scroll_to_last then
        state.scroll_to_last = false
        state.scrolled_offset = last_offset(self)
    end

    if child.measured_height <= self.measured_height then
        state.scrolled_offset = 0
    elseif state.scrolled_offset > last_offset(self) then
        state.scrolled_offset = last_offset(self)
    end
end

function class:draw(x, y)
    parent.draw(self, x, y)
    local child = self.children[1]
    assert(child.children)
    local current_offset = 0

    for _, view in ipairs(child.children) do
        if y >= self.y + self.measured_height then
            break
        end

        if current_offset >= self:get_state().scrolled_offset then
            view:draw(x, y)
            y = y + view.measured_height
        end

        current_offset = current_offset + view.measured_height
    end
end

return class
