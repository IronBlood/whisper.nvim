local M = {}

local target_ns = vim.api.nvim_create_namespace("whisper")

local state = {
	---@type WhisperStatus
	status = "idle",
	---@type integer|nil
	record_job = nil,
	---@type string|nil
	audiofile = nil,
	---@type integer|nil
	target_buf = nil,
	---@type integer|nil
	target_win = nil,
	---@type integer|nil
	target_mark = nil,
}

---@return WhisperStatus
function M.status()
	return state.status
end

---@param status WhisperStatus
function M.set_status(status)
	state.status = status
end

function M.is_recording()
	return state.status == "recording"
end

function M.is_busy()
	return state.status ~= "idle"
end

---@param job integer|nil
---@param audiofile string|nil
function M.set_recording(job, audiofile)
	state.record_job = job
	state.audiofile = audiofile
end

local function clear_target_mark()
	local buf = state.target_buf
	local mark = state.target_mark
	if buf and mark and vim.api.nvim_buf_is_valid(buf) then
		pcall(vim.api.nvim_buf_del_extmark, buf, target_ns, mark)
	end

	state.target_mark = nil
end

function M.capture_target()
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(win)

	clear_target_mark()

	state.target_buf = vim.api.nvim_get_current_buf()
	state.target_win = vim.api.nvim_get_current_win()
	state.target_mark = vim.api.nvim_buf_set_extmark(buf, target_ns, cursor[1] - 1, cursor[2], {
		right_gravity = false,
	})
end

---@return integer|nil
function M.record_job()
	return state.record_job
end

function M.clear_record_job()
	state.record_job = nil
end

---@return string|nil
function M.audiofile()
	return state.audiofile
end

function M.clear_audiofile()
	state.audiofile = nil
end

---@return {buf: integer|nil, win: integer|nil}
function M.target()
	return {
		buf = state.target_buf,
		win = state.target_win,
		mark = state.target_mark,
		ns = target_ns,
	}
end

function M.clear_target()
	clear_target_mark()
	state.target_buf = nil
	state.target_win = nil
end

function M.forget_target()
	state.target_buf = nil
	state.target_win = nil
	state.target_mark = nil
end

return M
