local BaseView = require('ui.base_view')
local BorderView = require('ui.border_view')
local HeroStatsView = require('game_screen.hero_stats_view')
local KeyBindingsView = require('game_screen.key_bindings_view')
local MapView = require('game_screen.map_view')
local MessageLogView = require('game_screen.message_log_view')
local RowView = require('ui.row_view')

local parent = BaseView
local class = setmetatable({}, { __index = parent })
class.__index = class

local function add_child(self, child, x, y)
    table.insert(
        self.children,
        {
            view = child,
            x = x,
            y = y
        }
    )
end

function class.new(options)
    local self = {
        children = {}
    }
    setmetatable(self, class)
    parent._init(self, options)
    return self
end

function class:measure(options)
    self:set_measured(options.width, options.height)

    local message_log_view = BorderView.new({
            title = 'Log',
            children = { MessageLogView.new({}) }
    })
    message_log_view:measure({
            width = self.measured_width,
            height = 20
    })
    add_child(
        self,
        message_log_view,
        0,
        self.measured_height - message_log_view.measured_height
    )

    local hero_stats_view = BorderView.new({
            title = 'Stats',
            children = { HeroStatsView.new({}) }
    })
    hero_stats_view:measure({
            width = 30,
            height = self.measured_height - message_log_view.measured_height
    })
    add_child(self, hero_stats_view, 0, 0)

    local key_bindings_view = BorderView.new({
            title = 'Key bindings',
            children = { KeyBindingsView.new({}) }
    })
    key_bindings_view:measure({
            width = 30,
            height = self.measured_height - message_log_view.measured_height
    })
    add_child(
        self,
        key_bindings_view,
        self.measured_width - key_bindings_view.measured_width,
        0
    )

    local map_view = BorderView.new({
            title = string.format(
                            'Dungeon level %s',
                            globals.screens:current().level_count
            ),
            children = { MapView.new({}) }
    })
    map_view:measure({
            width = self.measured_width
                - hero_stats_view.measured_width
                - key_bindings_view.measured_width,
            height = self.measured_height
                - message_log_view.measured_height
    })
    add_child(
        self,
        map_view,
        hero_stats_view.measured_width,
        0
    )
end

function class:draw(x, y)
    parent.draw(self, x, y)

    for _, child in ipairs(self.children) do
        child.view:draw(x + child.x, y + child.y)
    end
end

return class
