local M = {}

---@type WhisperConfig
local config = {
	endpoint = "http://127.0.0.1:8080/inference",
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

return M
