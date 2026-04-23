local config = require("whisper.config")
local session = require("whisper.session")
local recorder = require("whisper.recorder")
local client = require("whisper.client")
local editor = require("whisper.editor")
local notify = require("whisper.notify")

local M = {}

---@param msg string
---@param level? integer
local function send_notification(msg, level)
	notify.send(config.get().notify, msg, level)
end

local function cleanup_audiofile()
	local audiofile = session.audiofile()
	if not audiofile then
		return
	end

	recorder.cleanup(audiofile)
	session.clear_audiofile()
end

local function transcribe_file(audiofile)
	session.set_status("transcribing")
	send_notification("Transcribing...")

	client.transcribe(config.get().endpoint, audiofile, function(text, err)
		if err then
			cleanup_audiofile()
			session.clear_target()
			session.set_status("idle")
			send_notification(err, vim.log.levels.ERROR)
			return
		end

		cleanup_audiofile()
		session.set_status("idle")
		editor.insert_text(text, session.target(), config.get().insert_newline, send_notification)
		session.forget_target()
		send_notification("Transcription inserted")
	end)
end

local function handle_recorder_exit(code)
	if session.status() ~= "recording" then
		return
	end

	if code == 0 or session.record_job() == nil then
		return
	end

	session.set_status("idle")
	send_notification("Recorder exited unexpectedly", vim.log.levels.ERROR)
	cleanup_audiofile()
	session.clear_target()
end

function M.status()
	return session.status()
end

function M.is_recording()
	return session.is_recording()
end

function M.is_busy()
	return session.is_busy()
end

function M.start()
	if session.status() ~= "idle" then
		send_notification("Already busy: " .. session.status(), vim.log.levels.WARN)
		return
	end

	local job, audiofile_or_err = recorder.start(handle_recorder_exit)
	if not job then
		send_notification(audiofile_or_err, vim.log.levels.ERROR)
		return
	end

	session.set_recording(job, audiofile_or_err)
	session.set_status("recording")
	send_notification("Recording...")
end

function M.stop()
	if session.status() ~= "recording" then
		send_notification("Not recording", vim.log.levels.WARN)
		return
	end

	local job = session.record_job()
	local audiofile = session.audiofile()

	session.capture_target()
	session.clear_record_job()

	if job then
		recorder.stop(job)
	end

	if not audiofile then
		session.set_status("idle")
		send_notification("Audio file was not created", vim.log.levels.ERROR)
		return
	end

	recorder.wait_until_ready(audiofile, function(ok, err)
		if not ok then
			session.set_status("idle")
			send_notification(err or "Unknown" --[[ TODO Replace better message ]], vim.log.levels.ERROR)
			cleanup_audiofile()
			return
		end

		transcribe_file(audiofile)
	end, config.get().recorder.ready)
end

function M.toggle()
	if M.is_recording() then
		M.stop()
	elseif session.status() == "idle" then
		M.start()
	else
		send_notification("Busy: " .. session.status(), vim.log.levels.WARN)
	end
end

---@param opts? WhisperConfigOpts
function M.setup(opts)
	config.setup(opts)
end

return M
