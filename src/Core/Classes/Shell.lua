local TableUtils = require("TableUtils")
local StringUtils = require("StringUtils")

local Shell = {}
Shell.__index = Shell

function Shell.new()
    local shell = {
        _cache = {},

        LogHistory = {},
        CommandHistory = {},
        Input = "",
        Autofiller = nil,
    }

    return setmetatable(shell, Shell)
end

function Shell:WriteLine(line, ...)
    local text = TableUtils.concat({...}, " ")

    if self._cache[line] ~= text then
        term.setCursorPos(1, line)
        term.write(text)
        self._cache[line] = text
    end
end

function Shell:Blit(line, text)
    
end

function Shell:SetAutofiller(handler)
    self.Autofiller = handler
end

function Shell:Log(...)
    local text = TableUtils.concat({...}, " ")
    table.insert(self.LogHistory, text)
end

function Shell:render()
    local width, height = term.getSize()
    local usableWidth = width
    -- The last line is used for the command bar
    local usableHeight = height - 1

    -- Render the log history
    local logLineEnd
    do
        -- Get the most recent logs assuming they take up 1 line
        local log = TableUtils.select(-height, self.LogHistory)
        local wrappedLog = {}

        -- Wrap the logs if they don't fit the screen horizontally
        for _,logEntry in ipairs(log) do
            for _,substring in ipairs(StringUtils.split(logEntry, usableWidth)) do
                table.insert(wrappedLog, substring)
            end
        end
        wrappedLog = TableUtils.select(-usableHeight, wrappedLog)

        logLineEnd = math.min(usableHeight, #wrappedLog)
        for y = logLineEnd, 1, -1 do
            self:WriteLine(y, wrappedLog[y])
        end
    end

    -- Render the command bar
    do
        term.setCursorPos(1, logLineEnd + 1)
        term.clearLine()
        if math.floor(os.clock() * 2) % 2 == 0 then
            term.blit(">", "4", "f")
        else
            term.blit("> _", "400", "fff")
        end
    end
end

return Shell