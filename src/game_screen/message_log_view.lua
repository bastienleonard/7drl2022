local ColumnView = require('ui.column_view')
local TextView = require('ui.text_view')
local utils = require('utils')

local parent = ColumnView
local class = setmetatable({}, { __index = parent })
class.__index = class

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
    parent._init(self, options)
    init(self, options)
    return self
end

function class:__tostring()
    return 'MessagesLogView'
end

return class
