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

	local single_line = text:gsub("\n", " ")
	return { single_line }
end

---@param pos integer[]
---@param lines string[]
---@return integer[]
local function insertion_end(pos, lines)
	local last_line = lines[#lines] or ""

	if #lines == 1 then
		return { pos[1] + 1, pos[2] + #last_line }
	end

	return { pos[1] + #lines, #last_line }
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

	vim.schedule(function()
		local buf = target.buf
		if not buf then
			notify_fn("Target buffer is missing", vim.log.levels.ERROR)
			return
		end

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

			local win = target.win
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_cursor(win, insertion_end(pos, lines))
			end

			pcall(vim.api.nvim_buf_del_extmark, buf, target.ns, mark)
		end)
end

return M
