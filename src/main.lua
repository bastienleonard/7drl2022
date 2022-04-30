love.graphics.setDefaultFilter('nearest', 'nearest', 0)

local Config = require('config')
local fonts_cache = require('fonts_cache')
local GameScreen = require('game_screen.game_screen')
local PlayerInput = require('player_input')
local profiler = require('profiler')
local Screens = require('screens')
local Terminal = require('terminal')
local Kenney1Bit = require('tilesets.kenney_1bit')
local SourceCodePro = require('tilesets.source_code_pro')
local ui_scaled = require('ui_scaled')
local utils = require('utils')

local fps_font = fonts_cache.get(nil, ui_scaled(100))
local tilesets = {
    SourceCodePro,
    Kenney1Bit
}
local tileset_index = 1
local tile_size = 0

local function draw_fps()
    local text = string.format('%s FPS', love.timer.getFPS())
    love.graphics.setColor(unpack(require('colors').RED))
    love.graphics.print(
        text,
        fps_font,
        love.graphics.getWidth() - fps_font:getWidth(text),
        love.graphics.getHeight() - fps_font:getHeight()
    )
end

local function remake_terminal()
    local tileset = tilesets[tileset_index].new(tile_size)
    globals.terminal = Terminal.new(tileset)
end

local function increase_tile_size(delta)
    tile_size = utils.clamp(tile_size + delta, 0, 5)
    remake_terminal()
end

local function cycle_tileset(dx)
    assert(dx == -1 or dx == 1)
    tileset_index = tileset_index + dx

    if tileset_index < 1 then
        tileset_index = #tilesets - tileset_index
    elseif tileset_index > #tilesets then
        tileset_index = 1
    end

    assert(tileset_index >= 1)
    assert(tileset_index <= #tilesets)
    remake_terminal()
end

function love.load()
    globals = {}
    globals.config = Config.new()

    if globals.config.run_profiler then
        profiler.start()
    end

    remake_terminal()
    love.keyboard.setKeyRepeat(true)
    love.graphics.setBackgroundColor(unpack(globals.terminal.background_color))
    globals.screens = Screens.new()
    globals.screens:push(GameScreen.new())
end

function love.update(dt)
    profiler.update(dt)
end

function love.draw()
    globals.screens:current():draw()

    if globals.config.draw_fps then
        draw_fps()
    end
end

function love.keypressed(key, scancode, is_repeat)
    if scancode == 'return' and love.keyboard.isDown('lalt', 'ralt') then
        love.window.setFullscreen(not love.window.getFullscreen())
    else
        local input = PlayerInput.from_scancode(scancode)

        if input == PlayerInput.INCREASE_TILE_SIZE then
            increase_tile_size(1)
        elseif input == PlayerInput.DECREASE_TILE_SIZE then
            increase_tile_size(-1)
        elseif input == PlayerInput.CYCLE_TILESET_LEFT then
            cycle_tileset(-1)
        elseif input == PlayerInput.CYCLE_TILESET_RIGHT then
            cycle_tileset(1)
        else
            globals.screens:current():on_key_pressed(key, scancode, is_repeat)
        end
    end
end

function love.mousepressed(x, y, button, is_touch, presses)
    globals.screens:current():on_mouse_pressed(x, y, button, is_touch, presses)
end

function love.resize(width, height)
    remake_terminal()
end
