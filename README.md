# deftask

An asyc/await wrapper for Defold game engine

Web version -> [HTML5](https://magnatales.github.io/deftask-web/)

```lua
local task = require("deftask.task")

function init(_)
    local ct = task.cancellation.new("task_cancellation")
	run_async(function ()
		-- Waits for 5 seconds
		await(task.delay(5, ct))

		-- Waits until the predicate is met
		await(task.wait_until(function () return true end, ct))

		-- Waits until any task is completed
		await(task.when_any(task1(ct), task2(ct)))

		-- Waits until all tasks are completed
		await(task.when_all(task1(ct), task2(ct)))

		-- Waits for a certain amount of frames
		await(task.wait_frames(5, ct))

		-- Waits for a gui animation
		await(task.gui_animate(...))

		--- Waits for a go animation
		await(task.go_animate(...))
	end)
end
```

Create a your own task like this
```lua
local example_task = async(function(ct)
    print("Task started!")
    await(task.delay(5, ct))
    print("Finished delay!")
    await(task.wait_frames(1, ct))
    print("Finished waiting one frame!")
end)
```
So then you can use it like so:
```lua
run_async(function()
    await(example_task)
end)
```

If you want to debug the creation, completion, or cancellation of tasks, modify the settings inside async_config.lua
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
