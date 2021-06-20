local TableUtils = require("TableUtils")

local Signal = {}
Signal.__index = Signal

function Signal.new()
    local signal = {
        _connections = {},
    }

    return setmetatable(signal, Signal)
end

function Signal:Connect(handler)
    table.insert(self._connections, Instance.new("ScriptConnection", handler))
end

function Signal:Wait()
    local args, connection
    connection = Instance.new("ScriptConnection", function(...)
        connection:Disconnect()
        args = {...}
    end)
    table.insert(self._connections, connection)
    repeat
        wait()
    until args
    return args
end

function Signal:Fire(...)
    for i, connection in pairs(self._connections) do
        if connection.Connected then
            coroutine.wrap(connection.Fire)(connection, ...)
        else
            self._connections[i] = nil
        end
    end
    TableUtils.removeVoids(self._connections)
end

return Signal