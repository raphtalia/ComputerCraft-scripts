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

local NUMBERS = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

local function clear()
    term.clear()
    term.setCursorPos(0, 0)
end

local function input(text, ...)
    clear()
    print("\n".. text)
    return read(...)
end

local function choiceBoolean(text, trueOption, falseOption)
    while true do
        clear()
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
        clear()
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

local function getDiskDrives()
    local peripherals = {
        left = peripheral.wrap("left"),
        right = peripheral.wrap("right"),
        front = peripheral.wrap("front"),
        back = peripheral.wrap("back"),
        top = peripheral.wrap("top"),
        bottom = peripheral.wrap("bottom"),
    }
    local diskDrives = {}

    for _,diskDrive in pairs(peripherals) do
        if peripheral.getType(diskDrive) == "drive" then
            table.insert(diskDrives, diskDrive)
        end
    end

    return diskDrives
end

return function()
    local installPaths = {}

    local installChoice = choiceOptions(
        "> A disk drive with a floppy disk was detected, where would you like to install to?",
        {
            {NUMBERS[1], "Computer"},
            {NUMBERS[2], "Floppy disk"},
            {NUMBERS[3], "Both"},
        }
    )

    if installChoice == 1 or installChoice == 2 then
        installPaths = {"/rom"}
    end

    if installChoice == 2 or installChoice == 3 then
        local options = {}

        for _,diskDrive in ipairs(getDiskDrives()) do
            if diskDrive.hasData() then
                table.insert(options, {NUMBERS[#options + 1], diskDrive.getMountPath()})
            end
        end

        table.insert(installPaths, options[choiceOptions(
            "> Which floppy disk would you like to use?",
            options
        )][2])
    end

    clear()
    print("\nInstalling to")
    for _,path in ipairs(installPaths) do
        print("\n".. path)
    end
end