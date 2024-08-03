local co = coroutine
local awaitable = require("deftask.awaitable")
local logger = require("deftask.logger")
local isFunction = function(fun)
    return "function" == type(fun)
end

--- The async function decorator.
--- @param fun function @The function to make async.
--- @param id string|nil @The optional id of the task.
--- @return function @The async function.
async = function(fun, id)
    return function(...)
        if not isFunction(fun) then
            return
        end

        local thread = co.create(fun)
        local task = awaitable.GetTask(id)
        local next
        next = function(...)
            local success, moveNext = co.resume(thread, ...)
            if not success then
                logger.log(LogLevel.ERROR,"Error in coroutine: ".. moveNext)
                task.result = nil
                task:done()
                return
            end
            if co.status(thread) ~= "dead" then
                if isFunction(moveNext) then
                    moveNext(next)
                end
            else
                task.result = moveNext
                task:done()
            end
        end

        next(...)

        return task
    end
end

--- The await function.
--- @param task Task @The task to await.
--- @return any @The result of the task.
await = function(task)
    if task == nil or "table" ~= type(task) then
        return
    end

    if task.isCompleted == nil or task.isCompleted then
        return task.result
    end

    return co.yield(function(continuation)
        if task.isCompleted then
            continuation(task.result)
        else
            task:on_completed(continuation)
        end
    end)
end

run_async = function(fun, ...)
    async(fun, "run_async")(...)
end

