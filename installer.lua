--[[
    Main branch
    loadstring(http.get("https://raw.githubusercontent.com/raphtalia/ComputerCraft-scripts/main/installer.lua").readAll())()()
    OR
    pastebin run QjPNA4d0

    Development branch
    loadstring(http.get("https://raw.githubusercontent.com/raphtalia/ComputerCraft-scripts/development/installer.lua").readAll())()()
    OR
    pastebin run PRPGTyxj
]]

local function input(text, ...)
    print("\n".. text)
    return read(...)
end

local function choiceBoolean(text, trueOption, falseOption)
    while true do
        print(("\n%s\n[Y] %s\n[N] %s"):format(text, trueOption, falseOption))

        local eventData = {os.pullEvent("key")}
        local keyName = keys.getName(eventData[2])

        if keyName == "y" then
            return true
        elseif keyName == "n" then
            return false
        end
    end
end

local function choiceOptions(text, options)
    local keyedOptions = {}

    for i, option in ipairs(options) do
        local keyName = option[1]
        local optionText = option[2]

        keyedOptions[keyName] = {i, optionText}
    end

    while true do
        print("\n".. text)

        for key, option in pairs(keyedOptions) do
            print(("\n[%s] %s"):format(key, option[2]))
        end

        local eventData = {os.pullEvent("key")}
        local keyName = keys.getName(eventData[2])

        local option = keyedOptions[keyName]
        if option then
            return option[1]
        end
    end
end

return function()
    print(choiceBoolean(
        "this is a boolean",
        "this is the true option",
        "this is the false option"
    ))

    print(choiceOptions(
        "options prompt",
        {
            {"a", "uwu"},
            {"b", "owo"},
            {"one", "test1"},
            {"two", "test2"},
        }
    ))
end