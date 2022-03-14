local table_utils = require('table_utils')
local utils = require('utils')

return function(variants)
    local tagged_union = {}
    local names = {}

    for name, attrs in pairs(variants) do
        if names[name] then
            error(string.format('Duplicated name in tagged union: %s', name))
        end

        names[name] = true
        local variant = { name = name }
        tagged_union[name] = variant
        variant.new = function(...)
            local result = { variant = variant }
            local args = { ... }

            if #args ~= #attrs then
                error(
                    string.format(
                        '%s: provided %s arguments instead of %s',
                        name,
                        #args,
                        #attrs
                    )
                )
            end

            for i, arg in ipairs(args) do
                result[attrs[i]] = arg
            end

            result.is = function(self, variant)
                return self.variant.name == variant.name
            end
            return setmetatable(
                result,
                {
                    __tostring = utils.make_to_string(
                        variant.name,
                        unpack(attrs)
                    )
                }
            )
        end
    end

    return tagged_union
end
