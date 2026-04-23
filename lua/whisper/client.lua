local M = {}

---@param endpoint string
---@param audiofile string
---@return string[]
local function build_command(endpoint, audiofile)
	return {
		"curl",
		"-sS",
		"-X",
		"POST",
		"-F",
		"file=@" .. audiofile,
		endpoint,
	}
end

---@param body string|nil
---@return string|nil, string|nil
local function parse_response(body)
	if not body or body == "" then
		return nil, "empty response"
	end

	local ok, decoded = pcall(vim.json.decode, body)
	if not ok or type(decoded) ~= "table" then
		return nil, "invalid json response: " .. body
	end

	local text = decoded.text or decoded.transcript
	if type(text) ~= "string" or text == "" then
		return nil, "response did not contain transcription text"
	end

	return text, nil
end

---@param endpoint string
---@param audiofile string
---@param callback fun(text: string|nil, err: string|nil)
function M.transcribe(endpoint, audiofile, callback)
	local cmd = build_command(endpoint, audiofile)
	vim.system(cmd, { text = true }, function(result)
		local stdout = result.stdout or ""
		local stderr = result.stderr or ""

		if result.code ~= 0 then
			callback(nil, "Transcription failed: " .. stderr)
			return
		end

		local text, err = parse_response(stdout)
		if err then
			callback(nil, err)
			return
		end

		callback(text, nil)
	end)
end

return M
