local array_utils = require('array_utils')
local ColumnView = require('ui.column_view')
local TextView = require('ui.text_view')

local parent = ColumnView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function make_ui()
    local x = {
        { 'h', 'Move ←' },
        { 'l', 'Move →' },
        { 'j', 'Move ↓' },
        { 'k', 'Move ↑' },
        { 'y', 'Move ↖' },
        { 'u', 'Move ↗' },
        { 'b', 'Move ↙' },
        { 'n', 'Move ↘' },
        { '.', 'Skip turn' }
    }
    return array_utils.map(
        x,
        function(item)
            local scancode = item[1]
            local description = item[2]
            return string.format(
                '[%s] %s',
                love.keyboard.getKeyFromScancode(scancode),
                description
            )
        end
    )
end

function class.new(options)
    local self = {}
    options.children = array_utils.map(
        make_ui(),
        function(row)
            return TextView.new({ text = row })
        end
    )
    parent._init(self, options)
    setmetatable(self, class)
    return self
end

return class
