local GameScreen = require('game_screen.game_screen')
local PlayerInput = require('player_input')
local Screens = require('screens')
local Terminal = require('terminal')
local ui_scaled = require('ui_scaled')
local utils = require('utils')

local function increase_font_size(delta)
    local new_size = globals.terminal.font_size + delta

    if new_size > ui_scaled(10) and new_size < ui_scaled(40) then
        globals.terminal = Terminal.new(new_size)
    end
end

function love.load()
    love.keyboard.setKeyRepeat(true)
    globals = {}
    globals.terminal = Terminal.new()
    love.graphics.setBackgroundColor(unpack(globals.terminal.background_color))
    globals.screens = Screens.new()
    globals.screens:push(GameScreen.new())
end

function love.draw()
    globals.screens:current():draw()
end

function love.keypressed(key, scancode, is_repeat)
    if scancode == 'return' and love.keyboard.isDown('lalt', 'ralt') then
        love.window.setFullscreen(not love.window.getFullscreen())
    else
        local input = PlayerInput.from_scancode(scancode)

        if input == PlayerInput.INCREASE_FONT_SIZE then
            increase_font_size(1)
        elseif input == PlayerInput.DECREASE_FONT_SIZE then
            increase_font_size(-1)
        else
            globals.screens:current():on_key_pressed(key, scancode, is_repeat)
        end
    end
end

function love.mousepressed(x, y, button, is_touch, presses)
    globals.screens:current():on_mouse_pressed(x, y, button, is_touch, presses)
end

function love.resize(width, height)
    globals.terminal = Terminal.new(globals.terminal.font_size)
end
