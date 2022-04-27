local array_utils = require('array_utils')
local ColumnView = require('ui.column_view')
local make_class = require('make_class')
local TextView = require('ui.text_view')

local class = make_class(
    'KeyBindingsView',
    {
        _parent = ColumnView
    }
)

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
        { '.', 'Skip turn' },
        { 'pagedown', 'Scroll messages down' },
        { 'pageup', 'Scroll messages up' },
        { '-', 'Decrease font size' },
        { '=', 'Increase font size' }
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

function class._init(self, options)
    options.children = array_utils.map(
        make_ui(),
        function(row)
            return TextView.new({ text = row })
        end
    )
    class.parent._init(self, options)
end

return class
