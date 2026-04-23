local M = {}

local HEADER_SIZE = 44

---@param outfile string
---@return string[]
local function build_command(outfile)
	return {
		"pw-record",
		"--rate",
		"16000",
		"--channels",
		"1",
		outfile,
	}
end

---@return string
local function temp_audiofile()
	return vim.fn.tempname() .. ".wav"
end

---@param on_exit fun(code: integer)
---@return integer|nil, string|nil
function M.start(on_exit)
	local outfile = temp_audiofile()
	local job = vim.fn.jobstart(build_command(outfile), {
		detach = false,
		on_exit = function(_, code, _)
			on_exit(code)
		end,
	})

	if job <= 0 then
		return nil, "Failed to start recorder"
	end

	return job, outfile
end

---@param job integer
function M.stop(job)
	vim.fn.jobstop(job)
end

---@param audiofile string
function M.cleanup(audiofile)
	if vim.fn.filereadable(audiofile) == 1 then
		pcall(vim.fn.delete, audiofile)
	end
end

---@param audiofile string
---@param callback fun(ok: boolean, err: string|nil)
---@param opts? { timeout_ms?: integer, interval_ms?: integer }
function M.wait_until_ready(audiofile, callback, opts)
	local timeout_ms = opts and opts.timeout_ms or 1000
	local interval_ms = opts and opts.interval_ms or 50
	local deadline = vim.uv.now() + timeout_ms

	local function check()
		if vim.fn.filereadable(audiofile) == 1 then
			local size = vim.fn.getfsize(audiofile)
			if size > HEADER_SIZE then
				callback(true, nil)
				return
			end
		end

		if vim.uv.now() >= deadline then
			if vim.fn.filereadable(audiofile) ~= 1 then
				callback(false, "Audio file was not created")
				return
			end

			callback(false, "Recorded audio is empty")
			return
		end

		vim.defer_fn(check, interval_ms)
	end

	check()
end

return M
