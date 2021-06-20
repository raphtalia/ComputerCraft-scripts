local function concat(...)
    local args = {...}

    for i,v in pairs(args) do
        args[i] = tostring(v)
    end

    return table.concat(args)
end

local LogService = {
    MessageOut = Instance.new("Signal")
}

local Logs = {}

function LogService.print(...)
    local log = {
        Type = "print",
        Message = concat(...),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.warn(...)
    local log = {
        Type = "warn",
        Message = concat(...),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.error(...)
    local log = {
        Type = "error",
        Message = concat(...),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.info(...)
    local log = {
        Type = "info",
        Message = concat(...),
    }
    LogService.MessageOut:Fire(log.Message, log.Type)
    table.insert(Logs, log)
end

function LogService.getLogHistory()
    return {unpack(Logs)}
end

return LogService