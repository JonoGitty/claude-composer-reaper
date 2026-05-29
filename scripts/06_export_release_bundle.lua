-- 06_export_release_bundle.lua
-- Turns a finished master WAV into a complete release bundle:
--   - a 320 kbps MP3 for sharing
--   - a waveform peaks JSON for website waveform displays
-- It puts both next to the WAV in a folder named after the track.
--
-- WHY THIS EXISTS
--   Rendering settings in REAPER are powerful and fiddly, so this script does
--   NOT try to render for you. You render your master the normal way
--   (File > Render), then run this on the resulting WAV. That keeps the fragile
--   part (render config) in REAPER's own dialog, where it belongs, and lets this
--   script do the boring, repeatable part reliably.
--
-- REQUIREMENTS (install once, free)
--   - ffmpeg            (brew install ffmpeg)        makes the MP3
--   - audiowaveform     (brew install audiowaveform) makes the peaks JSON, from the BBC
--   On macOS with Homebrew both are one command each. This script is written for
--   macOS and Linux. On Windows, ask your assistant for a Windows version.
--
-- HOW TO RUN
--   1. Render your master to WAV in REAPER.
--   2. Run this script. A file picker opens.
--   3. Choose your master WAV. The MP3 and peaks file appear in a new folder.

local os_name = reaper.GetOS()
if os_name:find("Win") then
  reaper.ShowMessageBox(
    "This version targets macOS and Linux (it uses /bin/sh, ffmpeg and audiowaveform).\n" ..
    "Ask your assistant for a Windows variant.", "claude-composer-reaper", 0)
  return
end

-- Pick the master WAV.
local ok, wav = reaper.GetUserFileNameForRead("", "Choose your master WAV", "wav")
if not ok then return end

-- Split into directory, basename (no extension).
local dir = wav:match("^(.*)[/\\][^/\\]*$") or "."
local file = wav:match("[^/\\]*$")
local base = file:gsub("%.[^.]+$", "")

local outdir = dir .. "/" .. base .. "_release"
local mp3 = outdir .. "/" .. base .. ".mp3"
local peaks = outdir .. "/" .. base .. ".json"

-- Build one shell command: make the folder, then the MP3, then the peaks file.
-- Paths are single-quoted to survive spaces. (If a path contains a single
-- quote, ask your assistant to adjust the quoting.)
local cmd = "/bin/sh -c \"" ..
  "mkdir -p '" .. outdir .. "' && " ..
  "ffmpeg -y -i '" .. wav .. "' -b:a 320k '" .. mp3 .. "' && " ..
  "audiowaveform -i '" .. wav .. "' -o '" .. peaks .. "' -b 8" ..
  "\""

reaper.ShowConsoleMsg("Running export. This can take a few seconds...\n")
local result = reaper.ExecProcess(cmd, 0)

if not result then
  reaper.ShowConsoleMsg("Failed to start the command. Are ffmpeg and audiowaveform installed?\n" ..
    "Install with: brew install ffmpeg audiowaveform\n")
  return
end

-- ExecProcess returns: exit code on the first line, then the command output.
local exit_code = result:match("^(%-?%d+)")
reaper.ShowConsoleMsg(result .. "\n")

if exit_code == "0" then
  reaper.ShowConsoleMsg(
    "Done.\n" ..
    "  MP3:   " .. mp3 .. "\n" ..
    "  Peaks: " .. peaks .. "\n" ..
    "Both are in: " .. outdir .. "\n")
else
  reaper.ShowConsoleMsg(
    "Something went wrong (exit code " .. tostring(exit_code) .. ").\n" ..
    "Most likely ffmpeg or audiowaveform is not installed, or a path has an odd character.\n" ..
    "Install: brew install ffmpeg audiowaveform\n" ..
    "Then paste the output above to your assistant and it will sort it out.\n")
end
