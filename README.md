# whisper.nvim

Record audio in Neovim, send it to a Whisper / OpenAI-compatible ASR service, and insert the transcription back into the buffer.

## Requirements

- Neovim
- `pw-record`
- `curl`
- A Whisper / OpenAI-compatible ASR endpoint

## Installation

Using `lazy.nvim`:

```lua
{
  "IronBlood/whisper.nvim",
  config = function()
    require("whisper").setup({
      endpoint = "http://127.0.0.1:8080/inference",
    })
  end,
}
```

## Configuration

Default configuration:

```lua
require("whisper").setup({
  endpoint = "http://127.0.0.1:8080/inference",
  insert_newline = false,
  notify = true,
  recorder = {
    ready = {
      timeout_ms = 1000,
      interval_ms = 50,
    },
  },
})
```

Options:

- `endpoint`: ASR server endpoint.
- `insert_newline`: when `true`, keep newline breaks from the transcription.
- `notify`: enable `vim.notify` messages.
- `recorder.ready.timeout_ms`: how long to wait for the recorded audio file to be finalized after stopping.
- `recorder.ready.interval_ms`: how often to check whether the audio file is ready.

The ASR service is expected to return JSON containing either `text` or `transcript`.

## Usage

Suggested keymaps:

```lua
local whisper = require("whisper")

vim.keymap.set("n", "<leader>ww", whisper.toggle, { desc = "Whisper toggle recording" })
vim.keymap.set("n", "<leader>wj", whisper.start, { desc = "Whisper start recording" })
vim.keymap.set("n", "<leader>wk", whisper.stop, { desc = "Whisper stop recording" })
```

Workflow:

1. Call `setup()` during startup.
2. Press your start or toggle mapping to begin recording.
3. Press your stop or toggle mapping again to finish recording.
4. The audio is sent to the configured endpoint.
5. The returned transcription is inserted at the captured cursor position.

Available functions:

- `require("whisper").setup(opts)`
- `require("whisper").start()`
- `require("whisper").stop()`
- `require("whisper").toggle()`
- `require("whisper").status()`
- `require("whisper").is_recording()`
- `require("whisper").is_busy()`
