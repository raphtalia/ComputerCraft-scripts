local Environment = {
    _CC_DEFAULT_SETTINGS = _CC_DEFAULT_SETTINGS,
    _ENV = _ENV,
    _VERSION = _VERSION,
    _HOST = _HOST,

    window = window,
    string = string,
    xpcall = xpcall,
    fs = fs,
    tostring = tostring,
    print = print,
    vector = vector,
    debug = debug,
    settings = settings,
    unpack = unpack,
    rednet = rednet,
    getfenv = getfenv,
    parallel = parallel,
    paintutils = paintutils,
    setmetatable = setmetatable,
    next = next,
    disk = disk,
    rawlen = rawlen,
    ipairs = ipairs,
    keys = keys,
    io = io,
    rawequal = rawequal,
    redstone = redstone,
    bit32 = bit32,
    getmetatable = getmetatable,
    http = http,
    sleep = sleep,
    tonumber = tonumber,
    utf8 = utf8,
    rawset = rawset,
    peripheral = peripheral,
    write = write,
    bit = bit,
    os = os,
    help = help,
    term = term,
    math = math,
    pairs = pairs,
    pcall = pcall,
    textutils = textutils,
    gps = gps,
    type = type,
    coroutine = coroutine,
    table = table,
    select = select,
    load = load,
    rawget = rawget,
    loadstring = loadstring,
    read = read,
    colors = colors,
    setfenv = setfenv,
    dofile = dofile,
    error = error,
    loadfile = loadfile,
    turtle = turtle,
    multishell = multishell,
    pocket = pocket,
}
local Modules = {}

function Environment.assert(condition, error)
    if condition then
        Environment.error(error)
    end
end

function Environment.require(path)
    if Modules[path] then
        return Modules[path]
    elseif fs.exists(path) then
        local file = fs.open(path, "r")

        local ok, e = loadstring(file:readAll())
        if ok then
            local func = setfenv(ok, Environment)

            file:close()
            local module = func()
            Modules[path] = module
            return module
        else
            error(("\n[Error] %s\n%s"):format(path, e))
        end
    else
        local waitStart = os.time()
        while true do
            sleep()
            if Modules[path] then
                return Modules[path]
            end
            if os.time() - waitStart > 3 then
                error(("\n[Error] Yielded for %s to load"):format(path))
            end
        end
    end
end

function Environment.wait(n)
    n = math.max(n or 0.05, 0.05)

    local thread = coroutine.running()
    local ParallelService = Environment.require("ParallelService")
        if ParallelService then
        ParallelService.delay(n, function()
            print("RESUMING")
            coroutine.resume(thread)
        end)
        coroutine.yield()
    else
        error("wait() cannot be used at this time")
    end
end

Environment._G = Environment
return {
    Environment = Environment,
    Modules = Modules,
}