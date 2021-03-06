local utf8 = require('utf8')

local make_class = require('make_class')

local class = make_class('Text')

function class._init(self, lua_string)
    assert(lua_string)
    self.lua_string = lua_string
end

function class:length()
    if not self._length then
        self._length = utf8.len(self.lua_string)
    end

    return self._length
end

function class:text_at(i)
    return class.new(
        self.lua_string:sub(
            utf8.offset(self.lua_string, i),
            utf8.offset(self.lua_string, i + 1) - 1)
    )
end

function class.__concat(a, b)
    if type(a) ~= 'string' then
        a = a.lua_string
    end

    if type(b) ~= 'string' then
        b = b.lua_string
    end

    return class.new(a .. b)
end

class.EMPTY = class.new('')

return class
