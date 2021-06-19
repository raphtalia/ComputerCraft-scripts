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
    -- https://stackoverflow.com/questions/1426954/split-string-in-lua
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
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