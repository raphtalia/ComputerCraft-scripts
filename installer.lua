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
    -- https://github.com/Reselim/Base64/blob/master/Base64.lua

    local BUILD_STRING_CHUNK_SIZE = 4096

    local function build(values)
        local chunks = {}

        for index = 1, #values, BUILD_STRING_CHUNK_SIZE do
            table.insert(chunks, string.char(
                unpack(values, index, math.min(index + BUILD_STRING_CHUNK_SIZE - 1, #values))
            ))
        end

        return table.concat(chunks, "")
    end

    function Base64.decode(source)
        local sourceLength = #source

        local outputLength = (sourceLength / 3) * 4
        local output = {}

        for index = 0, (sourceLength / 4) - 1 do
            local inputIndex = bit32.lshift(index, 2) + 1
            local outputIndex = index * 3 + 1

            local value1, value2, value3, value4 = string.byte(source, inputIndex, inputIndex + 3)

            if value1 >= 97 then -- a-z
                value1 = value1 - 71 -- 97 - 26
            elseif value1 >= 65 then -- A-Z
                value1 = value1 - 65 -- 65 - 0
            elseif value1 >= 48 then -- 0-9
                value1 = value1 + 4 -- 52 - 48
            elseif value1 == 47 then -- /
                value1 = 63
            elseif value1 == 43 then -- +
                value1 = 62
            elseif value1 == 61 then -- =
                value1 = 0
            end

            if value2 >= 97 then -- a-z
                value2 = value2 - 71 -- 97 - 26
            elseif value2 >= 65 then -- A-Z
                value2 = value2 - 65 -- 65 - 0
            elseif value2 >= 48 then -- 0-9
                value2 = value2 + 4 -- 52 - 48
            elseif value2 == 47 then -- /
                value2 = 63
            elseif value2 == 43 then -- +
                value2 = 62
            elseif value2 == 61 then -- =
                value1 = 0
            end

            if value3 >= 97 then -- a-z
                value3 = value3 - 71 -- 97 - 26
            elseif value3 >= 65 then -- A-Z
                value3 = value3 - 65 -- 65 - 0
            elseif value3 >= 48 then -- 0-9
                value3 = value3 + 4 -- 52 - 48
            elseif value3 == 47 then -- /
                value3 = 63
            elseif value3 == 43 then -- +
                value3 = 62
            elseif value3 == 61 then -- =
                value1 = 0
            end

            if value4 >= 97 then -- a-z
                value4 = value4 - 71 -- 97 - 26
            elseif value4 >= 65 then -- A-Z
                value4 = value4 - 65 -- 65 - 0
            elseif value4 >= 48 then -- 0-9
                value4 = value4 + 4 -- 52 - 48
            elseif value4 == 47 then -- /
                value4 = 63
            elseif value4 == 43 then -- +
                value4 = 62
            elseif value4 == 61 then -- =
                value1 = 0
            end

            -- Combine all variables into one 24-bit variable to be split up
            local compound = bit32.bor(
                bit32.lshift(value1, 18),
                bit32.lshift(value2, 12),
                bit32.lshift(value3, 6),
                value4
            )

            output[outputIndex] = bit32.rshift(compound, 16)
            output[outputIndex + 1] = bit32.band(bit32.rshift(compound, 8), 255)
            output[outputIndex + 2] = bit32.band(compound, 255)
        end

        -- If the last couple of characters were padding, remove them from the output
        if string.byte(source, sourceLength) == 61 then
            output[outputLength] = nil
        end
        if string.byte(source, sourceLength - 1) == 61 then
            output[outputLength - 1] = nil
        end

        return build(output)
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
                url = url.. ("?%s=%s"):format(name, tostring(value))
            else
                url = url.. ("&%s=%s"):format(name, tostring(value))
            end
            i = i + 1
        end

        local response, e = http.get(
            url,
            {
                Authorization = "Basic ".. GithubAPI.Token
            }
        )
        if not response then
            error(e)
        end

        return textutils.unserializeJSON(response:readAll())
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
        return get("/git/blobs/".. sha)
    end
end

local Installer = {} do
    function Installer._makeFile(path, sha)
        print("Making ".. path)
        local blob = GithubAPI.getBlob(sha)

        local file, e = fs.open(path, "w")
        if not file then
            error(e)
        end

        if blob.encoding == "base64" then
            file.write(Base64.decode(blob.content))
        else
            error(("Unknown encoding type %q"):format(blob.encoding))
        end
        file.close()
    end

    function Installer._makeTree(path, sha)
        print("Making ".. path)
        local tree = GithubAPI.getTree(sha)

        for _,obj in ipairs(tree.tree) do
            if obj.type == "blob" then
                Installer._makeFile(("%s/%s"):format(path, obj.path), obj.sha)
            elseif obj.type == "tree" then
                Installer._makeTree(("%s/%s"):format(path, obj.path), obj.sha)
            end
        end
    end

    function Installer.install(path)
        local commit = GithubAPI.listCommits()[1]

        print("Installing commit ".. commit.sha)

        Installer._makeTree(path, commit.sha)
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
        installPaths = {"/.raphtalia"}
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
                    table.insert(installPaths, floppyDiskPath.. "/.raphtalia")
                    break
                end
            else
                table.insert(installPaths, floppyDiskPath.. "/.raphtalia")
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
        Installer.install(path)
    end
end