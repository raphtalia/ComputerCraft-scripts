local MathUtils = {}

local function round(x)
    return x + 0.5 - (x + 0.5) % 1
end

function MathUtils.round(x, accuracy)
    return round(x / accuracy) * accuracy
end

function MathUtils.ceil(x, accuracy)
    return math.ceil(x / accuracy) * accuracy
end

function MathUtils.floor(x, accuracy)
    return math.floor(x / accuracy) * accuracy
end

return MathUtils