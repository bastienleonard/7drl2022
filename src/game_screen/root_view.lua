local BaseView = require('ui.base_view')
local BorderView = require('ui.border_view')
local HeroStatsView = require('game_screen.hero_stats_view')
local KeyBindingsView = require('game_screen.key_bindings_view')
local make_class = require('make_class')
local MapView = require('game_screen.map_view')
local MessageLogView = require('game_screen.message_log_view')
local RowView = require('ui.row_view')
local ScrollView = require('ui.scroll_view')
local utils = require('utils')

local class = make_class(
    'RootView',
    {
        _parent = BaseView
    }
)

class.ID_MESSAGES_SCROLL_VIEW = 'messages_scroll_view'

local function add_child(self, child, dx, dy)
    assert(dx >= 0)
    assert(dy >= 0)
    child.dx = dx
    child.dy = dy
    table.insert(self.children, child)
end

local function make_child_sizes(width, height)
    local function size(width, height)
        return {
            width = width or -1,
            height = height or -1
        }
    end

    local result = {}
    result.hero_stats = size()
    result.map = size()
    result.key_bindings = size()
    result.messages = size()

    if width >= 35 * 2 + 40 then
        result.hero_stats.width = 35
        result.key_bindings.width = 35
    else
        result.hero_stats.width = 0
        result.key_bindings.width = 0
    end

    result.map.width = width
        - result.hero_stats.width
        - result.key_bindings.width
    result.messages.width = width

    if height >= 20 then
        result.messages.height = utils.clamp(math.floor(height / 3), 3, 20)
    else
        result.messages.height = 0
    end

    result.hero_stats.height = height - result.messages.height
    result.map.height = height - result.messages.height
    result.key_bindings.height = height - result.messages.height

    return result
end

function class._init(self, options)
    class.parent._init(self, options)
    self.children = {}
end

function class:measure(options)
    self:set_measured(options.width, options.height)
    local child_sizes = make_child_sizes(
        self.measured_width,
        self.measured_height
    )
    local message_log_view = BorderView.new({
            title = 'Log',
            children = {
                ScrollView.new({
                        id = class.ID_MESSAGES_SCROLL_VIEW,
                        children = { MessageLogView.new({}) }
                })
            }
    })
    message_log_view:measure({
            width = child_sizes.messages.width,
            height = child_sizes.messages.height
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
            width = child_sizes.hero_stats.width,
            height = child_sizes.hero_stats.height
    })
    add_child(self, hero_stats_view, 0, 0)

    local key_bindings_view = BorderView.new({
            title = 'Key bindings',
            children = { KeyBindingsView.new({}) }
    })
    key_bindings_view:measure({
            width = child_sizes.key_bindings.width,
            height = child_sizes.key_bindings.height
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
            add_child_padding = false,
            children = { MapView.new({}) }
    })
    map_view:measure({
            width = child_sizes.map.width,
            height = child_sizes.map.height
    })
    add_child(
        self,
        map_view,
        hero_stats_view.measured_width,
        0
    )
end

function class:draw(x, y)
    class.parent.draw(self, x, y)

    for _, child in ipairs(self.children) do
        child:draw(x + child.dx, y + child.dy)
    end
end

return class
