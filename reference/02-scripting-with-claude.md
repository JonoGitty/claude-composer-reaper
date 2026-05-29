# Scripting REAPER with Claude

This is the everyday workflow and the reason this repo exists. You do not write the code. You describe the job, the assistant writes a Lua script, you run it, and if it breaks you paste the error back. Most useful tools take two or three rounds of this.

## The loop

1. Open your `Scripts/` folder in Claude Code (see `01-getting-started.md`).
2. Describe the task in plain English, with the music outcome and any rules.
3. The assistant writes a `.lua` file into the folder.
4. In REAPER, load and run it (or reload if it is already in your action list).
5. If it errors, copy the text from REAPER's console and paste it back to the assistant.
6. Repeat until it does the job, then bind it to a shortcut or toolbar button.

## Writing a good request

The more concrete you are about the musical outcome, the better the first draft. Compare:

Weak: "make a track script"

Strong: "Write a REAPER Lua script that finds every track whose name contains 'vox', colours them a warm red, puts them in a folder called VOCALS, and routes that folder to a new bus called VOX BUS. Use only native ReaScript functions. Wrap it in an undo block."

The strong version names the trigger (tracks containing "vox"), the actions (colour, folder, route), and the constraints (native functions, undo block). That is most of the work.

## Rules to put in every request

Ask the assistant to follow these. They are the difference between a script you can trust and one that wrecks a session:

- Wrap changes in `reaper.Undo_BeginBlock()` and `reaper.Undo_EndBlock("name", -1)` so one undo reverses everything.
- Use `reaper.PreventUIRefresh(1)` before any loop and `reaper.PreventUIRefresh(-1)` plus `reaper.UpdateArrange()` after, so the screen does not flicker and the run is faster.
- Use `reaper.ShowConsoleMsg(text .. "\n")` to print progress while debugging.
- Do not invent API functions. If unsure a function exists, say so.

A prompt you can paste at the start of a session:

> You are helping me write REAPER Lua ReaScripts. Prefer Lua. Use only ReaScript API functions you are confident exist; if unsure, say so rather than guessing. Wrap every change in an undo block. Quieten the UI during loops. Add ShowConsoleMsg debug lines I can remove later. Explain what the script does in one line before the code.

## When it errors

REAPER prints script errors to the console with a line number, like:

```
script.lua:14: attempt to call a nil value (field 'GetTrackName')
```

Copy that whole line and paste it back. "nil value" on an API call almost always means the function name is slightly wrong or does not exist. The assistant fixes it and resends. This is normal and expected, not a sign anything is broken.

## Stopping the assistant from hallucinating API calls

This is the single most common failure. REAPER has hundreds of functions and an LLM will sometimes confidently use one that does not exist. Two defences:

1. Tell it not to guess (the prompt above does this).
2. Give it real references to work from. Inside REAPER, `Help > ReaScript documentation` opens the full list. You can keep a copy of known-good scripts in your folder so the assistant has correct examples to copy from. The scripts in this repo are written against the documented API for exactly this reason.

## Where good scripts end up

Once a script works, you make it part of how you use REAPER:

- Assign a keyboard shortcut in the action list.
- Add it to a toolbar as a button with an icon.
- Add it to a custom menu.
- Trigger it from a MIDI controller (with ReaLearn, an SWS feature).

That is when REAPER stops being someone else's DAW and starts being yours.
