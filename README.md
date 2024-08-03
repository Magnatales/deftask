# deftask

(WIP)

An asyc/await wrapper for Defold game engine

Web version -> [HTML5](https://magnatales.github.io/deftask-web/)

If you want to debug the creation, completation or cancellation of tasks, modify the settings inside async_config.lua
```lua
return {
    enabled = false, -- Set this to false to disable logging
    log_available =
    {
        [AsyncLogType.CREATED] = true,
        [AsyncLogType.COMPLETED] = true,
        [AsyncLogType.CANCELLED] = true,
        [AsyncLogType.WASCANCELLED] = true,
    }
}
```
