local MathUtils = require("MathUtils")

local StringUtils = {}

function StringUtils.collapse(str, pattern)
    local rep = pattern
    pattern = pattern:rep(2)
    repeat
        str = str:gsub(pattern, rep)
	until not str:match(pattern)
    return str
end

function StringUtils.split(inputstr, sep)
    local t = {}
    if type(sep) == "string" then
        -- https://stackoverflow.com/questions/1426954/split-string-in-lua
        if sep == nil then
            sep = "%s"
        end

        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
    elseif type(sep) == "number" then
        for i = 1, MathUtils.ceil(#inputstr, sep), sep do
            table.insert(t, inputstr:sub(i, i + sep - 1))
        end
    end

    return t
end

function StringUtils.chars(str)
    local i = 1
    return function()
        local char = str:sub(i, i)
        if char ~= "" then
            i = i + 1
            return char
        else
            return nil
        end
    end
end

return StringUtils