--[[
    Main branch
    loadstring(http.get("https://raw.githubusercontent.com/raphtalia/ComputerCraft-scripts/main/installer.lua").readAll())()("main")
    OR
    pastebin run exJHax7T

    Development branch
    loadstring(http.get("https://raw.githubusercontent.com/raphtalia/ComputerCraft-scripts/development/installer.lua").readAll())()("development")
    OR
    pastebin run kHWhQ5AT
]]

local NUMBERS = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

local Base64 = {} do
    function Base64.decode()
        
    end
end

local GithubAPI = {
    RepositoryUrl = "https://api.github.com/repos/raphtalia/ComputerCraft-Scripts",
    Branch = "main",
    Token = "",
} do
    -- Ported from https://github.com/raphtalia/GithubLuaAPI

    local function get(path, queryParams)
        local url = GithubAPI.RepositoryUrl.. path

        local i = 1
        for name, value in pairs(queryParams or {}) do
            if i == 1 then
                url ..= ("?%s=%s"):format(name, tostring(value))
            else
                url ..= ("&%s=%s"):format(name, tostring(value))
            end
            i = i + 1
        end

        return textutils.unserializeJSON(http.get(
            url,
            {
                Authorization = "Basic ".. GithubAPI.Token
            }
        ):readAll())
    end

    function GithubAPI.listCommits()
        return get(
            "/commits",
            {
                sha = GithubAPI.Branch,
            }
        )
    end

    function GithubAPI.getTree(sha)
        return get("/git/trees/".. sha)
    end

    function GithubAPI.getBlob(sha)
        return get("/git/blos/".. sha)
    end
end

local function clear()
    term.clear()
    term.setCursorPos(0, 0)
end

local function input(text, ...)
    clear()
    print(("\n%s "):format(text))
    return read(...)
end

local function choiceBoolean(text, trueOption, falseOption)
    clear()
    print(("\n%s\n[Y] %s\n[N] %s"):format(text, trueOption or "Yes", falseOption or "No"))

    while true do
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

    clear()
    print("\n".. text)

    for key, option in pairs(keyedOptions) do
        print(("\n[%s] %s"):format(key, option[2]))
    end

    while true do
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

local function install(path)
    local commit = GithubAPI.listCommits()[1]
    for i,v in pairs(commit) do
        print(i,v)
    end
end

return function(repositoryBranch)
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

        while true do
            local floppyDiskPath = options[choiceOptions(
                "> Which floppy disk would you like to use?",
                options
            )][2]

            if fs.exists(floppyDiskPath.. "/startup") or fs.exists(floppyDiskPath.. "/startup.lua") then
                if choiceBoolean("> This floppy disk already contains a startup file would you like to override it?") then
                    table.insert(installPaths, floppyDiskPath)
                    break
                end
            else
                table.insert(installPaths, floppyDiskPath)
                break
            end
        end
    end

    if choiceBoolean("> Would you like to use a Github API token to avoid ratelimiting?") then
        GithubAPI.Token = input("Github API Token", "*")
    end

    clear()
    print("\nInstalling to")
    for _,path in ipairs(installPaths) do
        print("\n".. path)
    end

    GithubAPI.Branch = repositoryBranch

    for _,path in ipairs(installPaths) do
        install(path)
    end
end