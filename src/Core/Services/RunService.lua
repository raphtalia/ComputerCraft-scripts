local TableUtils = require("TableUtils")

local RunService = {}

local BindedToRenderStep = {}

function RunService:IsTurtle()
    if turtle then
        return true
    else
        return false
    end
end

function RunService:IsPocket()
    if pocket then
        return true
    else
        return false
    end
end

function RunService:IsComputer()
    if not RunService:IsTurtle() and not RunService:IsPocket() then
        return true
    else
        return false
    end
end

function RunService:IsAdvanced()
    if term.isColor() then
        return true
    else
        return false
    end
end

function RunService:BindToRenderStep(name, priority, callback)
    BindedToRenderStep[name] = {
        Priority = priority,
        Callback = callback,
    }
end

function RunService:UnbindFromRenderStep(name)
    BindedToRenderStep[name] = nil
end

function RunService:_render()
    local callbacks = {}
    for _,callback in pairs(BindedToRenderStep) do
        callbacks[callback.Priority] = callback.Callback
    end
    TableUtils.removeVoids(callbacks)

    for _,callback in ipairs(callbacks) do
        callback()
    end
end

return RunService