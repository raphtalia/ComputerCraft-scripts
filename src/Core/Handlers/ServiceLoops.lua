local RunService = require("RunService")

local Tasks = require("ParallelService").Tasks

return function()
    if #Tasks > 0 then
        if os.clock() > Tasks[1].ScheduledExecution then
            local task = table.remove(Tasks, 1)
            task.Callback(unpack(task.Arguments))
        end
    end

    RunService._render()

    sleep(0.05)
end