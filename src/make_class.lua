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
        local self = setmetatable({}, class)
        self.class = class
        class._init(self, ...)
        return self
    end
    class.is_instance = function(o)
        if o == nil or type(o) == 'number' then
            return false
        end

        local o_class = o.class

        while true do
            if o_class == class then
                return true
            end

            if o_class.parent then
                o_class = o_class.parent
            else
                return false
            end
        end

        return false
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
