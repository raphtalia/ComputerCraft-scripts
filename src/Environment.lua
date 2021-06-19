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
    assert = assert,
    rawlen = rawlen,
    ipairs = ipairs,
    keys = keys,
    io = io,
    rawequal = rawequal,
    redstone = redstone,
    bit32 = bit32,
    getmetatable = getmetatable,
    http = http,
    wait = sleep,
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
    tyep = type,
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
}
local Modules = {}

function Environment.require(path)
    if Modules[path] then
        return Modules[path]
    else
        local file = fs.open(path, "r")

        local ok, e = loadstring(file:readAll())
        if ok then
            local func = setfenv(ok, Environment)

            file:close()
            local module = func()
            Modules[path] = module
            return module
        else
            error(("\n%s\n%s"):format(path, e))
        end
    end
end

-- TODO: More long-term replacement for newproxy
function Environment.newproxy(metatable)
    if metatable then
        return setmetatable({}, {})
    else
        return {}
    end
end

Environment._G = Environment
return {
    Environment = Environment,
    Modules = Modules,
}