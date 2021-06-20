local ROOT_PATH = fs.getDir(shell.getRunningProgram())
local SRC_PATH = ROOT_PATH.. "/.raphtalia/src"
local CORE_PATH = SRC_PATH.. "/Core"

local LIBRARIES_PATH = CORE_PATH.. "/Libraries"
local SERVICES_PATH = CORE_PATH.. "/Services"
local HANDLERS_PATH = CORE_PATH.. "/Handlers"

local Environment
local Modules

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
                    fs.getName(path),
                    Directory = fs.getDir(path),
                    Path = path,
                }
            },
            {__index = env}
        )
        return loadfile(path, env)(...)
    else
        env = setmetatable(
            {
                script = {
                    fs.getName(path),
                    Directory = fs.getDir(path),
                    Path = path,
                }
            },
            {__index = env}
        )
        return loadfile(path, env)(...)
    end
end

local function getFileName(name)
    return name:match("(.+)%..+") or name
end

local envModule = setmetatable(require(CORE_PATH.. "/Environment.lua"), {__index = _G})
Environment = envModule.Environment
Modules = envModule.Modules

-- Some variants cannot be easily injected
Environment.shell = shell

for _,libraryName in ipairs(fs.list(LIBRARIES_PATH)) do
    print("Loading library ".. libraryName)
    Modules[getFileName(libraryName)] = require(("%s/%s"):format(LIBRARIES_PATH, libraryName), Environment)
end

-- Some libraries get to be global
Environment.Instance = Environment.require("Instance")

local Requires = {}

for _,serviceName in ipairs(fs.list(SERVICES_PATH)) do
    table.insert(Requires, function()
        print("Loading service ".. serviceName)
        Modules[getFileName(serviceName)] = require(("%s/%s"):format(SERVICES_PATH, serviceName), Environment)
    end)
end

parallel.waitForAll(unpack(Requires))

local LogService = Environment.require("LogService")
Environment.print = LogService.print
Environment.warn = LogService.warn
Environment.error = LogService.error
Environment.info = LogService.info

local Handlers = {}

for _,handlerName in ipairs(fs.list(HANDLERS_PATH)) do
    print("Loading handler ".. handlerName)
    local handler = require(("%s/%s"):format(HANDLERS_PATH, handlerName), Environment)
    if type(handler) == "function" then
        table.insert(Handlers, handler)
    elseif type(handler) == "table" then
        for _,func in ipairs(handler) do
            table.insert(Handlers, func)
        end
    end
end

-- TODO: Integrate with LogService
-- Replace error handlers with more detailed ones
Environment.error = function(message)
    message = message or ""

    local env = getfenv(3)
    if env.script then
        error(("\n%s: %s\n%s\nStack End"):format(env.script.Path, message, debug.traceback("Stack Begin", 2)), 3)
    else
        error(("\nUnknown: %s\n%s\nStackEnd"):format(message, message, debug.traceback("Stack Begin", 2)), 3)
    end
end

--[[
    Run all handlers at the same time, handlers are in charge of keeping track
    of their state.
]]
--[[
while true do
    parallel.waitForAny(unpack(Handlers))
end
]]
local Parallel = Environment.require("Parallel")
while true do
    Parallel.waitForAny(Handlers, nil, 0.05)
end