local array_utils = require('array_utils')
local make_class = require('make_class')

local class = make_class('Screens')

function class._init(self)
    self.screens = {}
end

function class:current()
    if #self.screens == 0 then
        error('No game screen registered')
    end

    return array_utils.last(self.screens)
end

function class:push(screen)
    table.insert(self.screens, screen)
end

function class:pop()
    array_utils.pop(self.screens)
end

function class:replace_top(screen)
    self.screens[#self.screens] = screen
end

return class
