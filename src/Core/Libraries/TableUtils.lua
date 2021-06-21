local TableUtils = {}

function TableUtils.removeVoids(tab)
    table.sort(tab, function(a)
        return a ~= nil and true or false
    end)
    return tab
end

function TableUtils.select(n, tab)
    local length = #tab
    local values = {}

    if n < 0 and -n > length then
        return tab
    end

    for i = (n % length), length do
        table.insert(values, tab[i])
    end

    return values
end

function TableUtils.concat(args, sep)
    for i,v in pairs(args) do
        args[i] = tostring(v)
    end

    return table.concat(args, sep)
end

return TableUtils