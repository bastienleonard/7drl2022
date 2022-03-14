local module = {}

function module.keys_count(t)
    assert(t)
    local result = 0

    for _, _ in pairs(t) do
        result = result + 1
    end

    return result
end

function module.keys(t)
    assert(t)
    local result = {}

    for key, _ in pairs(t) do
        table.insert(result, key)
    end

    return result
end

function module.dup(t)
    local result = {}

    for key, value in pairs(t) do
        result[key] = value
    end

    return result
end

function module.remove_by_key(t, key)
    assert(t)
    assert(key ~= nil)
    local result = t[key]
    t[key] = nil
    return result
end

return module
