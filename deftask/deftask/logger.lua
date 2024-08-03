local async_config = require("deftask.async_config")

local M = {}

--- Prints a line.
---@param ... any @The message to print.
local function print_line(...)
	print("[ASYNC] ".. debug.getinfo(3).short_src .. ":" .. debug.getinfo(3).currentline .. " -> " .. ...)
end

--- Logs a message.
---@param log_level LogLevel @The log level.
---@param ... any @The message to log.
function M.log(log_level,...)

    local message = table.concat({...}, " ")
    local log_type = message:match("%[.*%]")

    if not async_config.enabled and log_type and not log_type[AsyncLogType.ERROR] then
        return
    end

    if log_type and not async_config.log_available[log_type] then
        return
    end

    log_level = log_level or LogLevel.INFO
    if log_level == LogLevel.INFO then
        print_line("[INFO] ".. ...)
    elseif log_level == LogLevel.WARNING then
        print_line("[WARNING] " .. ...)
    elseif log_level == LogLevel.ERROR then
        print_line("[ERROR] ".. ...)
    end
end

return M