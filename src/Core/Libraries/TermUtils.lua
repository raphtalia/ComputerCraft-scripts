local TermUtils = {}

function TermUtils.clear()
    term.clear()
    term.setCursorPos(1, 1)
end

function TermUtils.clearLine()
    local _,y = term.getCursorPos()
    term.clearLine()
    term.setCursorPos(1, y)
end

function TermUtils.writeLine(...)
    TermUtils.clearLine()
    term.write(table.concat({...}, " "))
end

return TermUtils