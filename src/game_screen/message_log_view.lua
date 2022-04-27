local ColumnView = require('ui.column_view')
local make_class = require('make_class')
local TextView = require('ui.text_view')
local utils = require('utils')

local class = make_class(
    'MessageLogView',
    {
        _parent = ColumnView
    }
)

local function make_children()
    local children = {}
    local messages = globals.screens:current().messages

    for _, message in ipairs(messages) do
        local child = TextView.new({
                text = message
        })
        table.insert(children, child)
    end

    return children
end

local function init(self, options)
end

function class.new(options)
    local self = {}
    setmetatable(self, class)
    options.children = make_children()
    class.parent._init(self, options)
    init(self, options)
    return self
end

return class
