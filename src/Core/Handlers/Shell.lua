local State = {
    Text = ""
}

local UserInputService = require("UserInputService")
local CommandService = require("CommandService")
local LogService = require("LogService")
local TermUtils = require("TermUtils")

TermUtils.clear()
--[[
local function autofill(text)
    State.Text = text
    return CommandService.autofillCommand(text)
end

UserInputService.Char:Connect(function(char)
    State.Text = State.Text.. char
end)

UserInputService.InputBegan:Connect(function(input)
    local keyName = input.Name
    if keyName == "tab" then
        local autofillResult = autofill(State.Text)
        if #autofillResult > 0 then
            State.Text = State.Text.. autofillResult[1]
        end
    elseif keyName == "enter" then
        if State.Text ~= "" then
            local text = State.Text
            TermUtils.writeLine(text)
            State.Text = ""
            CommandService.runCommand(text)
        end
    end
end)

UserInputService.InputContinue:Connect(function(input)
    if input.Name == "backspace" then
        State.Text = State.Text:sub(1, #State.Text - 1)
    end
end)

return function()
    TermUtils.clearLine()
    read(nil, nil, autofill, State.Text)
end
]]

local Shell = Instance.new("Shell")

require("RunService"):BindToRenderStep("Shell", 1, function()
    Shell:render()
end)

return function()
    sleep(0.05)
end