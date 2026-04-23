local M = {}

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
	state.target_buf = vim.api.nvim_get_current_buf()
	state.target_win = vim.api.nvim_get_current_win()
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
	}
end

return M
