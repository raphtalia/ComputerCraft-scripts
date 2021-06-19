local Command = {}
Command.__index = Command

function Command.new(arguments, flags)
    local command = {
        Arguments = arguments,
        Flags = flags
    }

    return setmetatable(command, Command)
end

return Command