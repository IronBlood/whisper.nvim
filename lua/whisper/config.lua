local M = {}

---@type WhisperConfig
local config = {
	endpoint = "http://127.0.0.1:8080/inference",
	endpoints = {},
	insert_newline = false,
	notify = true,
	recorder = {
		ready = {
			timeout_ms = 1000,
			interval_ms = 50,
		},
	},
}

---@return WhisperConfig
function M.get()
	return config
end

---@param opts? WhisperConfigOpts
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

---@param endpoint? WhisperEndpoint|WhisperActionOpts
---@return string
function M.resolve_endpoint(endpoint)
	if type(endpoint) == "table" then
		endpoint = endpoint.endpoint
	end

	if type(endpoint) ~= "string" or endpoint == "" then
		return config.endpoint
	end

	return config.endpoints[endpoint] or endpoint
end

return M
