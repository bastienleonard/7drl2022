return function(...)
    local names = { ... }
    local enum = {
        __tostring = function(self) return self.name end
    }
    enum.__index = enum
    enum.all = {}

    for _, name in ipairs(names) do
        local variant = setmetatable({ name = name }, enum)
        enum[name] = variant
        table.insert(enum.all, variant)
    end

    return enum
end
