local EventService = require("EventService")

local UserInputService = {
    InputBegan = Instance.new("Signal"),
    InputEnded = Instance.new("Signal"),
    InputContinue = Instance.new("Signal"),
    Char = EventService.getEvent("char"),
}

local Keys = {}

function UserInputService:IsKeyDown(keyName)
    return Keys[keyName] or false
end

EventService.getEvent("key"):Connect(function(keyCode)
    local inputObject = Instance.new("InputObject", keyCode)
    if not Keys[inputObject.Name] then
        Keys[inputObject.Name] = true
        UserInputService.InputBegan:Fire(inputObject)
    else
        UserInputService.InputContinue:Fire(inputObject)
    end
end)

EventService.getEvent("key_up"):Connect(function(keyCode)
    local inputObject = Instance.new("InputObject", keyCode)
    if Keys[inputObject.Name] then
        Keys[inputObject.Name] = false
        UserInputService.InputEnded:Fire(inputObject)
    end
end)

return UserInputService