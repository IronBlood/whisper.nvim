local M = {}

---@param text string
---@param insert_newline boolean
---@return string[]
local function build_lines(text, insert_newline)
	text = text:gsub("\r\n", "\n")
	text = text:gsub("\r", "\n")

	if insert_newline then
		return vim.split(text, "\n", { plain = true })
	end

	return { text:gsub("\n", " ") }
end

---@param text string|nil
---@param target { buf: integer|nil, win: integer|nil, mark: integer|nil, ns: integer }
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

		local mark = target.mark
		if not mark then
			notify_fn("Target insertion point is missing", vim.log.levels.ERROR)
			return
		end

		local pos = vim.api.nvim_buf_get_extmark_by_id(buf, target.ns, mark, {})
		if #pos ~= 2 then
			notify_fn("Target insertion point is no longer valid", vim.log.levels.ERROR)
			return
		end

		local lines = build_lines(text, insert_newline)
		vim.api.nvim_buf_set_text(buf, pos[1], pos[2], pos[1], pos[2], lines)
		pcall(vim.api.nvim_buf_del_extmark, buf, target.ns, mark)
	end)
end

return M
