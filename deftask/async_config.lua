require("deftask.async_cons")

return {
    enabled = true, -- Set this to false to disable logging
    log_available =
    {
        [AsyncLogType.CREATED] = true,
        [AsyncLogType.COMPLETED] = true,
        [AsyncLogType.CANCELLED] = true,
        [AsyncLogType.WASCANCELLED] = true,
    }
}