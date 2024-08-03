require("deftask.async")
local awaitable = require("deftask.awaitable")
local logger = require("deftask.logger")
local CreateTask = awaitable.GetTask
local IsAwaiter = awaitable.IsAwaiter

local Task = {}

--- Creates a task that completes in the next frame.
--- @param ct CancellationToken @The cancellation token.
--- @return Task @The task.
Task.yield = function(ct)
    return Task.wait_frames(1, ct)
end

--- Creates a task that completes after a delay.
--- @param seconds number @The delay in seconds.
--- @param ct CancellationToken @The cancellation token.
--- @return Task @The task.
Task.delay = function(seconds, ct)
    local cuid = 0
    local id = "Task.delay " .. seconds .. "s with ct: " .. (ct and ct.id or "nil ct")
    local task = CreateTask(id)
    local handler = timer.delay(seconds, false, function()
        logger.log(LogLevel.INFO, AsyncLogType.COMPLETED .. " {" .. id .."}")
        if ct then
            ct:unregister(cuid)
        end
        task:done()
    end)
    if ct then
        cuid = ct:register(function()
            logger.log(LogLevel.INFO, AsyncLogType.WASCANCELLED .. " Task {" .. id .."}")
            timer.cancel(handler)
        end)
    end
    return task
end

Task.wait_until = function(predicate, ct)
    local cuid = 0
    local id = "Task.wait_until with ct: " .. (ct and ct.id or "nil ct")
    local task = CreateTask(id)
    local handler
    handler = timer.delay(0, true, function()
        if predicate() then
            logger.log(LogLevel.INFO, AsyncLogType.COMPLETED .. " {" .. id .."}")
            if ct then
                ct:unregister(cuid)
            end
            task:done()
            timer.cancel(handler)
        end
    end)
    if ct then
        cuid = ct:register(function()
            logger.log(LogLevel.INFO, AsyncLogType.WASCANCELLED .. " Task {" .. id .."}")
            timer.cancel(handler)
        end)
    end
    return task
end

--- Creates a task that completes when any of the tasks complete.
--- @vararg Task
--- @return Task
Task.when_any = function(...)
    ---@type string
    local awaiters_id = ""
    local awaiters = {...}
    for _, v in ipairs({...}) do
        awaiters_id = awaiters_id .. "{".. v.id .. "} "
    end
    local task = CreateTask("Task.when_any with tasks: " .. awaiters_id)

    if #awaiters == 0 then
        task:done()
        return task
    end

    local done = function()
        logger.log(LogLevel.INFO, AsyncLogType.COMPLETED ..  " {Task.WhenAny} with tasks: " .. awaiters_id)
        task:done()
    end
    for _, v in ipairs(awaiters) do
        if IsAwaiter(v) then
            if v.isCompleted then
                task:done()
            else
                v:on_completed(done)
            end
        else
            logger.log(LogLevel.ERROR, "{Task.WhenAny} Awaiter is not a valid awaiter")
        end
    end
    return task
end

--- Creates a task that completes when all of the tasks complete.
--- @vararg Task
--- @return Task
Task.when_all = function(...)
    local awaiters = {...}
    local awaiters_id = ""
    for _, v in ipairs({...}) do
        awaiters_id = awaiters_id .. "{".. v.id .. "} "
    end
    local task = CreateTask("Task.when_all with tasks: " .. awaiters_id)
    local taskLen = #awaiters

    if taskLen == 0 then
        task:done()
        return task
    end

    local doneCount = 0
    local done = function()
        doneCount = doneCount + 1
        if doneCount >= taskLen then
            logger.log(LogLevel.INFO, AsyncLogType.COMPLETED .. " {Task.WhenAll} with tasks: " .. awaiters_id)
            task:done()
        end
    end

    for i, v in ipairs(awaiters) do
        if IsAwaiter(v) then
            if v.isCompleted then
                done()
            else
                v:on_completed(done)
            end
        else
            logger.log(LogLevel.ERROR, "{Task.WhenAll} Awaiter", i, "is not a valid awaiter")
        end
    end

    return task
end

--- Creates a tasks that waits for certain amount of frames
--- @param frames number @The amount of frames to wait
--- @param ct CancellationToken @The cancellation token
--- @return Task @The task
Task.wait_frames = function(frames, ct)
    local cuid = 0
    local id = "Task.wait_frames " .. frames .. " frames with ct: " .. (ct and ct.id or "nil ct")
    local task = CreateTask(id)
    local count = 0
    local handler
    handler = timer.delay(0, true, function()
        count = count + 1
        if count >= frames then
            logger.log(LogLevel.INFO, AsyncLogType.COMPLETED .. " {" .. id .."}")
            if ct then
                ct:unregister(cuid)
            end
            timer.cancel(handler)
            task:done()
        end

    end)
    if ct then
        cuid = ct:register(function()
            logger.log(LogLevel.INFO, AsyncLogType.WASCANCELLED .. " Task {" .. id .."}")
            timer.cancel(handler)
        end)
    end
    return task
end

--- Create a task for a gui.animate
--- @param node userdata @The node to animate
--- @param property hash @The property to animate
--- @param to number|vector3|vector4 @The value to animate to
--- @param easing userdata @The easing function to use
--- @param duration number @The duration of the animation
--- @param delay number @The delay before the animation starts
--- @param complete_function function @The function to call when the animation is complete
--- @param ct CancellationToken @The cancellation token
--- @return Task @The task
Task.gui_animate = function(node, property, to, easing, duration, delay, complete_function, ct)
    local cuid = 0
    local id = "Task.gui_animate " .. node .. " " .. property .. " " .. (ct and ct.id or "nil ct")
    local task = CreateTask(id)

    gui.animate(node, property, to, easing, duration, delay, function()
        if ct then
            ct:unregister(cuid)
        end
        logger.log(LogLevel.INFO, AsyncLogType.COMPLETED .. " {" .. id .."}")
        task:done()
        if complete_function then
            complete_function()
        end
    end)

    if ct then
        cuid = ct:register(function()
            logger.log(LogLevel.INFO, AsyncLogType.WASCANCELLED .. " Task {" .. id .."}")
            gui.cancel_animation(node, property)
            task:done()
        end)
    end

    return task
end

--- Create a task for a go.animate
--- @param url hash @The url to animate
--- @param property hash @The property to animate
--- @param playback userdata @The playback mode
--- @param to number|vector3|vector4 @The value to animate to
--- @param easing userdata @The easing function to use
--- @param duration number @The duration of the animation
--- @param delay number @The delay before the animation starts
--- @param complete_function function @The function to call when the animation is complete
--- @param ct CancellationToken @The cancellation token
--- @return Task @The task
Task.go_animate = function(url, property, playback, to, easing, duration, delay, complete_function, ct)
    local cuid = 0
    local id = "Task.go_animate " .. url .. " " .. property .. " " .. (ct and ct.id or "nil ct")
    local task = CreateTask(id)

    go.animate(url, property, playback, to, easing, duration, delay, function()
        if ct then
            ct:unregister(cuid)
        end
        logger.log(LogLevel.INFO, AsyncLogType.COMPLETED .. " {" .. id .."}")
        task:done()
        if complete_function then
            complete_function()
        end
    end)

    if ct then
        cuid = ct:register(function()
            logger.log(LogLevel.INFO, AsyncLogType.WASCANCELLED .. " Task {" .. id .."}")
            go.cancel_animations(url, property)
            task:done()
        end)
    end

    return task
end

return Task
