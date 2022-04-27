local array_utils = require('array_utils')
local utils = require('utils')

local ALLOWED_OPTIONS = array_utils.map_to_table(
    { '_parent', '_to_string' },
    function(name)
        return name, true
    end
)

return function(name, options)
    options = options or {}

    for name, value in pairs(options) do
        if not ALLOWED_OPTIONS[name] then
            error(string.format('make_class(): unkown option %s', name))
        end
    end

    local class = {
        parent = options._parent,
        __tostring = options._to_string or utils.make_to_string(name)
   }
    class.__index = class
    class.new = function(...)
        local args = { ... }
        local self = setmetatable({}, class)
        self.class = class
        class._init(self, unpack(args))
        return self
    end
    setmetatable(
        class,
        {
            __index = class.parent,
            __tostring = function()
                return string.format('%s class', name)
            end
        }
    )
    return class
end
