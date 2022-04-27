local make_class = require('make_class')

local class = make_class('BaseScreen')

local function screen_coords_to_cells(x, y)
    local terminal = globals.terminal

    if x < terminal.x_offset then
        x = 0
    elseif x > love.graphics.getWidth() - terminal.x_offset then
        x = terminal.width - 1
    else
        x = math.floor((x - terminal.x_offset) / terminal.cell_width)
    end

    if y < terminal.y_offset then
        y = 0
    elseif y > love.graphics.getHeight() - terminal.y_offset then
        y = terminal.height - 1
    else
        y = math.floor((y - terminal.y_offset) / terminal.cell_height)
    end

    return x, y
end

function class._init(self)
end

function class:draw()
end

function class:on_key_pressed(key, scancode, is_repeat)
end

function class:on_mouse_pressed(x, y, button, is_touch, presses)
    if self.root_view then
        local cell_x, cell_y = screen_coords_to_cells(x, y)
        self.root_view:on_click(cell_x, cell_y)
    end
end

return class
