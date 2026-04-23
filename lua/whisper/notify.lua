local M = {}

---@param enabled boolean
---@param msg string
---@param level? integer
function M.send(enabled, msg, level)
	if not enabled then
		return
	end

	vim.schedule(function()
		vim.notify(msg, level or vim.log.levels.INFO)
	end)
end

return M
