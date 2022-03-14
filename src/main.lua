local GameScreen = require('game_screen.game_screen')
local Screens = require('screens')
local Terminal = require('terminal')
local utils = require('utils')

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
        globals.screens:current():on_key_pressed(key, scancode, is_repeat)
    end
end

function love.resize(width, height)
    globals.terminal = Terminal.new()
end
