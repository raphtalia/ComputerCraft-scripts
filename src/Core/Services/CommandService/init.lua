local FileUtils = require("FileUtils")
local StringUtils = require("StringUtils")

local CommandService = {
    Commands = {}
}

function CommandService.autofillCommand(text)
    if #text > 0 then
        local autofillOptions = {}

        for i in pairs(CommandService.Commands) do
            if i:sub(1, #text) == text then
                table.insert(autofillOptions, i:sub(#text + 1))
            end
        end

        return autofillOptions
    else
        return nil
    end
end

function CommandService.runCommand(text)
    local arguments = StringUtils.split(text, " ")
    local command = arguments[1]
    arguments = {select(2, unpack(arguments))}

    local flags = {}
    for i, argument in pairs(arguments) do
        if argument:sub(1, 2) == "--" then
            flags[argument:sub(3)] = true
            arguments[i] = nil
        elseif argument:sub(1, 1) == "-" then
            for char in StringUtils.chars(argument:sub(2)) do
                flags[char] = true
            end
            arguments[i] = nil
        end
    end
    table.sort(arguments)

    if CommandService.Commands[command] then
        CommandService.Commands[command].Handle(Instance.new("Command", arguments, flags))
    else
        print("Invalid command: ".. (command or "nil"))
    end
end

function CommandService.registerCommand(commandName, handler)
    CommandService.Commands[commandName] = handler
end

local path = Instance.new("Path", script.Directory)
for _,command in ipairs(path.Commands:GetChildren()) do
    CommandService.Commands[FileUtils.getNameWithoutExtension(command.Name)] = require(command.Path)
end

return CommandService