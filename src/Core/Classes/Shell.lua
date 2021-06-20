local Shell = {}
Shell.__index = Shell

function Shell.new()
    local shell = {
        _cache = {},

        Log = {},
        History = {},
        Input = "",
        Autofiller = nil,
    }

    return setmetatable(shell, Shell)
end

function Shell:WriteLine(line, text)
    if self._cache[line] ~= text then
        term.setCursorPos(1, line)
        term.write(text)
        self._cache[line] = text
    end
end

function Shell:SetAutofiller(handler)
    self.Autofiller = handler
end

function Shell:render()
    local width, height = term.getSize()
    --[[
    term.clear()
    for i = #self.Log, 1, -1 do
        term.setCursorPos()
    end
    ]]

    for y = height, 1, -1 do
        self:WriteLine(y, math.random())
    end
end

return Shell