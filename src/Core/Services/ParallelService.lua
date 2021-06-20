local ParallelService = {
    Tasks = {}
}

local function sortTasks(taskA, taskB)
    return taskA.ScheduledExecution > taskB.ScheduledExecution
end

function ParallelService.delay(delay, callback, ...)
    table.insert(
        ParallelService.Tasks,
        {
            ScheduledExecution = os.clock() + delay,
            Callback = callback,
            Arguments = {...},
        }
    )
    table.sort(ParallelService.Tasks, sortTasks)
end

return ParallelService