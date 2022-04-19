local BaseScreen = require('base_screen')
local ButtonView = require('ui.button_view')
local colors = require('colors')
local ColumnView = require('ui.column_view')
local PlayerInput = require('player_input')
local TextView = require('ui.text_view')
local utils = require('utils')

local parent = BaseScreen
local class = setmetatable({}, { __index = parent })
class.__index = class

local function init(self, options)
    self.items = {
        {
            text = 'New game',
            activate = function()
                local GameScreen = require('game_screen.game_screen')
                globals.screens:replace_top(GameScreen.new())
            end
        },
        {
            text = 'Quit',
            activate = function()
                love.event.quit()
            end
        }
    }
    self.current_item = 1
end

local function move_current_item_by(self, dy)
    self.current_item = utils.clamp(self.current_item + dy, 1, #self.items)
end

local function activate_current_item(self)
    self.items[self.current_item].activate()
end

function class.new()
    local self = {}
    parent._init(self, options)
    init(self, options)
    return setmetatable(self, class)
end

function class:draw()
    local terminal = globals.terminal
    local children = {
        TextView.new({ text = 'You died' }),
        TextView.new({ text = '' })
    }

    for i, item in ipairs(self.items) do
        local text_color = nil

        if i == self.current_item then
            text_color = colors.BLUE
        end

        local button = ButtonView.new({
                text = item.text,
                text_color = text_color,
                on_click = self.items[i].activate
        })
        table.insert(children, button)
    end

    self.root_view = ColumnView.new({
            children = children
    })
    self.root_view:measure({})
    self.root_view:draw(
        math.max(
            0,
            utils.round((terminal.width - self.root_view.measured_width) / 2)
        ),
        math.max(
            0,
            utils.round((terminal.height - self.root_view.measured_height) / 2)
        )
    )
end

function class:on_key_pressed(key, scancode, is_repeat)
    local input = PlayerInput.from_scancode(scancode)

    if input == PlayerInput.MOVE_UP then
        move_current_item_by(self, -1)
    elseif input == PlayerInput.MOVE_DOWN then
        move_current_item_by(self, 1)
    elseif input == PlayerInput.ACTIVATE then
        activate_current_item(self)
    end
end

return class
