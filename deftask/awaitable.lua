local logger = require("deftask.logger")

local isFunction = function(fun)
    return "function" == type(fun)
end

--- Returns an awaiter object.
---@return Task task The awaiter object.
local get_task = function(id)
    ---@class Task
    ---@field id string
    ---@field isCompleted boolean Whether the task is completed.
    ---@field onCompletedList table List of functions to call when the task is completed.
    ---@field result any The result of the task.
    local task = {
        id = id or "Default Awaiter",
        isCompleted = false,
        onCompletedList = {},
        result = nil
    }

    --- Adds a function to the list of functions to call when the task is completed.
    ---@param fun function The function to call when the task is completed.
    function task:on_completed(fun)
        if isFunction(fun) then
            table.insert(self.onCompletedList, fun)
        end
    end

    --- Calls the functions in the list of functions to call when the task is completed.
    function task:done()
        if self.isCompleted then
            return
        end
        self.isCompleted = true
        for _, v in ipairs(self.onCompletedList) do
            pcall(v, self.result)
        end
    end

    logger.log(LogLevel.INFO, AsyncLogType.CREATED .. " Task {" .. task.id .. "}")
    return task
end

--- Checks if the awaiter is a valid awaiter.
--- @param awaiter Task @The awaiter to check.
local is_awaiter = function(awaiter)
    if awaiter == nil or "table" ~= type(awaiter) or awaiter.isCompleted == nil then
        print ("awaiter is nil or not a table")
        return false
    end

    if awaiter.on_completed == nil or "function" ~= type(awaiter.on_completed) then
        return false
    end
    return true
end

return {
    GetTask = get_task,
    IsAwaiter = is_awaiter
}
