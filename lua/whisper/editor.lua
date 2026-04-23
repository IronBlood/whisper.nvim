local M = {}

---@param text string|nil
---@param target { buf: integer|nil, win: integer|nil }
---@param insert_newline boolean
---@param notify_fn fun(msg: string, level?: integer)
function M.insert_text(text, target, insert_newline, notify_fn)
	if not text or text == "" then
		notify_fn("Transcription was empty", vim.log.levels.WARN)
		return
	end

	local buf = target.buf
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_get_current_buf()
	end

	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			notify_fn("Target buffer is no longer valid", vim.log.levels.ERROR)
			return
		end

		local win = target.win
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_current_win(win)
		end

		local lines
		if insert_newline then
			lines = vim.split(text, "\n", { plain = true })
		else
			lines = { text }
		end

		vim.api.nvim_put(lines, "c", true, true)
	end)
end

return M
