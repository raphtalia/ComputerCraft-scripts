local TableUtils = require("TableUtils")

local LogService = {
    MessageOut = Instance.new("Signal")
}

local Logs = {}

function LogService.print(...)
    local log = {
        Type = "print",
        Message = TableUtils.concat({...}, " "),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.warn(...)
    local log = {
        Type = "warn",
        Message = TableUtils.concat({...}, " "),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.error(...)
    local log = {
        Type = "error",
        Message = TableUtils.concat({...}, " "),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.info(...)
    local log = {
        Type = "info",
        Message = TableUtils.concat({...}, " "),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.getLogHistory()
    return {unpack(Logs)}
end

return LogService