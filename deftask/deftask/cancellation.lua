local logger = require("deftask.logger")

--- Create a new token
---@return CancellationToken ct @Returns a new token
local new = function(id)
    ---@class CancellationToken
    ---@field cancellationRequested boolean
    local ct = {
        cancellationRequested = false,
        id = id,
        onCanceledList = {},
        ids = 0,
    }

    --- Register a callback to be called when the token is cancelled by id
    --- @param id string @The id of the callback
    --- @param callback function @The callback
    --- @return number @The id of the callback
    function ct:register(callback)
        ct.ids = ct.ids + 1
        if ct.onCanceledList[ct.ids] == nil then
            ct.onCanceledList[ct.ids] = {}
        end
        table.insert(ct.onCanceledList[ct.ids], callback)
        return ct.ids
    end

    --- Unregister a callback from the token by id
    --- @param id number @The id of the callback
    function ct:unregister(id)
        ct.onCanceledList[id] = nil
    end

    function ct:dispose()
        ct.onCanceledList = {}
    end

    --- Cancel the token and call all registered callbacks
    function ct:cancel()
        ct.cancellationRequested = true
        logger.log(LogLevel.INFO, AsyncLogType.CANCELLED .. " Token {" .. ct.id .. "}")
        for _, callbackList in pairs(ct.onCanceledList) do
            for _, callback in ipairs(callbackList) do
                pcall(callback)
            end
        end
    end

    logger.log(LogLevel.INFO, AsyncLogType.CREATED .. " Token {" .. ct.id .. "}")
    return ct
end

return {
    new = new
}