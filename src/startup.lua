local ROOT_PATH = fs.getDir(shell.getRunningProgram())
local SRC_PATH = ROOT_PATH.. "/.raphtalia/src/Core"

local LIBRARIES_PATH = SRC_PATH.. "/Libraries"
local SERVICES_PATH = SRC_PATH.. "/Services"
local HANDLERS_PATH = SRC_PATH.. "/Handlers"

local Environment = _G

local function require(path, env, ...)
    if fs.isDir(path) then
        return (loadfile(path.. "/init.lua", env) or loadfile(path.. "/main.lua", env))(...)
    else
        return (loadfile(path, env))(...)
    end
end

for _,libraryName in ipairs(fs.list(LIBRARIES_PATH)) do
    print("Loading library ".. libraryName)
    require(("%s/%s"):format(LIBRARIES_PATH, libraryName), Environment)
end

for _,serviceName in ipairs(fs.list(SERVICES_PATH)) do
    print("Loading service ".. serviceName)
    require(("%s/%s"):format(SERVICES_PATH, serviceName), Environment)
end

for _,handlerName in ipairs(fs.list(HANDLERS_PATH)) do
    print("Loading handler ".. handlerName)
    require(("%s/%s"):format(HANDLERS_PATH, handlerName), Environment)
end