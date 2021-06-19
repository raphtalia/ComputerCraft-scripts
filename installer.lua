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
local MAX_RETRIES = 5
local NUMBERS = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"}

local GithubAPI = {
    RepositoryUrl = "https://api.github.com/repos/raphtalia/ComputerCraft-Scripts",
    Branch = "main",
    Token = "",
} do
    -- Ported from https://github.com/raphtalia/GithubLuaAPI

    local function get(path, format, queryParams)
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

        local response
        local attempts = 0
        repeat
            local e
            response, e = http.get(
                url,
                {
                    ["accept"] = "application/".. format,
                    ["authorization"] = "Basic ".. GithubAPI.Token,
                    ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36 Edg/91.0.864.53",

                }
            )
            if not response then
                attempts = attempts + 1
                print(("\nRequest to %s failed\n%s\nStalling for 30 seconds then retrying (%d)"):format(url, e, attempts))
                sleep(30)
            end
        until response or attempts > MAX_RETRIES
        if not response then
            error(("Request failed after %d attempts"):format(MAX_RETRIES))
        end

        return response:readAll()
    end

    function GithubAPI.listCommits()
        return textutils.unserializeJSON(get(
            "/commits",
            "vnd.github.v3+json",
            {
                sha = GithubAPI.Branch,
            }
        ))
    end

    function GithubAPI.getTree(sha)
        return textutils.unserializeJSON(get(
            "/git/trees/".. sha,
            "vnd.github.v3+json"
        ))
    end

    function GithubAPI.getBlobRaw(sha)
        return get(
            "/git/blobs/".. sha,
            "vnd.github.VERSION.raw"
        )
    end

    function GithubAPI.getLatestCommit()
        return GithubAPI.listCommits()[1]
    end
end

local Installer = {
    InstallPaths = {},
} do
    function Installer._makeFile(path, sha)
        print("Copying ".. path)
        local raw = GithubAPI.getBlobRaw(sha)

        local file, e = fs.open(path, "w")
        if not file then
            error(e)
        end

        file.write(raw)
        file.close()
    end

    function Installer._makeTree(path, sha)
        print("Copying ".. path)
        local tree = GithubAPI.getTree(sha)

        for _,obj in ipairs(tree.tree) do
            if obj.type == "blob" then
                Installer._makeFile(("%s/%s"):format(path, obj.path), obj.sha)
            elseif obj.type == "tree" then
                Installer._makeTree(("%s/%s"):format(path, obj.path), obj.sha)
            end
        end
    end

    function Installer.install(path, commitSha)
        if fs.exists(path) then
            fs.delete(path)
        end

        local existingInstallPath = Installer.InstallPaths[commitSha]
        if existingInstallPath and existingInstallPath ~= path then
            -- We've already installed with this commit so lets reuse the last install
            print("Copying commit ".. commitSha)

            fs.copy(existingInstallPath, path)
        else
            -- We've never installed with this commit before
            print("Installing commit ".. commitSha)

            Installer._makeTree(path, commitSha)

            Installer.InstallPaths[commitSha] = path
        end

        local startUpPath = fs.getDir(path).. "/startup.lua"
        if fs.exists(startUpPath) then
            fs.delete(startUpPath)
        end
        fs.copy(path.. "/src/startup.lua", startUpPath)
    end
end

local function clear()
    term.clear()
    term.setCursorPos(0, 0)
end

local function input(text, ...)
    clear()
    print(("\n%s "):format(text))
    sleep(0.15)
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
    sleep(0.15)
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
    sleep(0.15)
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
    local diskDrives = {}
    local installChoice

    for _,diskDrive in ipairs(getDiskDrives()) do
        if diskDrive.hasData() then
            table.insert(diskDrives, diskDrive)
        end
    end

    if #diskDrives > 0 then
        installChoice = choiceOptions(
            "> A disk drive with a floppy disk was detected, where would you like to install to?",
            {
                {NUMBERS[1], "Computer"},
                {NUMBERS[2], "Floppy disk"},
                {NUMBERS[3], "Both"},
            }
        )
    else
        installChoice = 1
    end

    if installChoice == 1 or installChoice == 3 then
        installPaths = {"/.raphtalia"}
    end

    if installChoice == 2 or installChoice == 3 then
        local options = {}

        for _,diskDrive in ipairs(diskDrives) do
            table.insert(options, {NUMBERS[#options + 1], diskDrive.getMountPath()})
        end

        while true do
            local floppyDiskPath = options[choiceOptions(
                "> Which floppy disk would you like to use?",
                options
            )][2]

            if fs.exists(floppyDiskPath.. "/startup") or fs.exists(floppyDiskPath.. "/startup.lua") then
                if choiceBoolean("> This floppy disk already contains a startup file would you like to overwrite it?") then
                    table.insert(installPaths, floppyDiskPath.. "/.raphtalia")
                    break
                end
            else
                table.insert(installPaths, floppyDiskPath.. "/.raphtalia")
                break
            end
        end
    end

    if choiceBoolean("> Would you like to use a Github Personal Access Token for higher ratelimits?") then
        GithubAPI.Token = input("Github Personal Access Token", "*")
    end

    GithubAPI.Branch = repositoryBranch

    local commitSha = GithubAPI.getLatestCommit().sha
    if choiceBoolean(("> The latest commit is \n%s\nis this the correct commit?"):format(commitSha)) then
        --[[
            Mainly for development to ensure ComputerCraft is getting the
            correct commit
        ]]
        local installStart = os.clock()
        clear()
        print("\nInstalling to")
        for _,path in ipairs(installPaths) do
            print("\n".. path)
        end

        for _,installPath in ipairs(installPaths) do
            Installer.install(installPath, commitSha)
        end
        print(("\nInstallation finished in %d seconds"):format(os.clock() - installStart))

        print("\nRebooting in 3 seconds")
        sleep(3)
        os.reboot()
    else
        printError("\nInstallation aborted")
    end
end