local ROOT_PATH = fs.getDir(shell.getRunningProgram())
local SRC_PATH = ROOT_PATH.. "/.raphtalia/src"
local CORE_PATH = SRC_PATH.. "/Core"

local LIBRARIES_PATH = CORE_PATH.. "/Libraries"
local SERVICES_PATH = CORE_PATH.. "/Services"
local HANDLERS_PATH = CORE_PATH.. "/Handlers"

local Environment

local function require(path, env, ...)
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
        local ok, e = loadfile(path, env)
        if ok then
            return ok(...)
        else
            error(("\n%s\n%s"):format(path, e))
        end
    else
        env = setmetatable(
            {
                script = {
                    Directory = path
                }
            },
            env
        )
        local ok, e = loadfile(path, env)
        if ok then
            return ok(...)
        else
            error(("\n%s\n%s"):format(path, e))
        end
    end
end

Environment = setmetatable(require(CORE_PATH.. "/Environment.lua"), _G)

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