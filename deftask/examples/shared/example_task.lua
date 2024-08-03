local task = require("deftask.task")
local progress_bar = require("examples.shared.progress_bar")
local M = {}

--- Create a new progress bar task
--- @type fun(duration: number, id: string, ct: CancellationToken): Task
local task_progress_bar = async(function(duration, id, ct)
	local progress_bar = progress_bar:new(id)
	progress_bar:set_color(vmath.vector4(0.3, 0.6, 0.3, 1))
	local cuid = ct:register( function()
		progress_bar:set_color(vmath.vector4(0.8, 0, 0, 1))
		progress_bar:set_text(string.format(id .. " cancelled at %.0f%%", progress_bar.progress * 100))
	end)
	local timer = 0
	local progress = 0
	while(timer < duration) do
		timer = timer + DT
		progress = timer / duration
		progress_bar:update_progress(progress)
		await(task.yield(ct))
	end
	progress_bar:set_text(id .. " completed!")
	ct:unregister(cuid)
end)

M.task_progress_bar = task_progress_bar

return M;