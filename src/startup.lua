local ROOT_PATH = fs.getDir(shell.getRunningProgram())
local SRC_PATH = ROOT_PATH.. "/.raphtalia/src"
local CORE_PATH = SRC_PATH.. "/Core"

local LIBRARIES_PATH = CORE_PATH.. "/Libraries"
local SERVICES_PATH = CORE_PATH.. "/Services"
local HANDLERS_PATH = CORE_PATH.. "/Handlers"

local Environment

local function loadfile(path, env)
    local file = fs.open(path, "r")

    local ok, e = loadstring(file:readAll())
    if ok then
        local func = setfenv(ok, env)

        file:close()
        return func
    else
        error(("\n%s\n%s"):format(path, e))
    end
end

local function require(path, env, ...)
    print("ENVIRONMENT")
    for i,v in pairs(env) do
        print(i,v)
    end
    env = env or _G

    if fs.isDir(path) then
        if fs.exists(path.. "/init.lua") then
            path = path.. "/init.lua"
        elseif fs.exists(path.. "/main.lua") then
            path = path.. "/main.lua"
        end

        env = setmetatable(
            {
                script = {
                    Directory = fs.getDir(path),
                    Name = fs.getName(path),
                }
            },
            env
        )
        return loadfile(path, env)(...)
    else
        env = setmetatable(
            {
                script = {
                    Directory = path
                }
            },
            env
        )
        return loadfile(path, env)(...)
    end
end

Environment = setmetatable(require(SRC_PATH.. "/Environment.lua"), _G)

for _,libraryName in ipairs(fs.list(LIBRARIES_PATH)) do
    print("Loading library ".. libraryName)
    require(("%s/%s"):format(LIBRARIES_PATH, libraryName), Environment)
end

for _,serviceName in ipairs(fs.list(SERVICES_PATH)) do
    print("Loading service ".. serviceName)
    require(("%s/%s"):format(SERVICES_PATH, serviceName), Environment)
end

local parallelRequire = coroutine.wrap(require)
for _,handlerName in ipairs(fs.list(HANDLERS_PATH)) do
    print("Loading handler ".. handlerName)
    parallelRequire(("%s/%s"):format(HANDLERS_PATH, handlerName), Environment)
end