---@meta

---@alias WhisperStatus "idle" | "recording" | "transcribing"

---@class WhisperRecorderReadyConfig
---@field timeout_ms integer
---@field interval_ms integer

---@class WhisperRecorderConfig
---@field ready WhisperRecorderReadyConfig

---@class WhisperConfig
---@field endpoint string
---@field insert_newline boolean
---@field notify boolean
---@field recorder WhisperRecorderConfig

---@class WhisperRecorderReadyConfigOpts
---@field timeout_ms? integer
---@field interval_ms? integer

---@class WhisperRecorderConfigOpts
---@field ready? WhisperRecorderReadyConfigOpts

---@class WhisperConfigOpts
---@field endpoint? string
---@field insert_newline? boolean
---@field notify? boolean
---@field recorder? WhisperRecorderConfigOpts
