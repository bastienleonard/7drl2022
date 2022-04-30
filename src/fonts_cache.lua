local module = {}

local cache = {}

function module.get(path, size)
    assert(size)
    local cache_key = string.format('%s-%s', size, path)
    local font = cache[cache_key]

    if not font then
        print(string.format('Loading font with size %s at path %s', size, path))

        if path then
            font = love.graphics.newFont(path, size)
        else
            font = love.graphics.newFont(size)
        end

        cache[cache_key] = font
    end

    return font
end

return module
