# Starter prompts

Copy these into Claude Code (with this skill installed) and adjust. They are written to get a usable first draft. The more you say about the musical outcome, the better the result.

## Session opener

Paste this once at the start of a scripting session to set the ground rules:

> You are helping me write REAPER Lua ReaScripts. Prefer Lua. Use only ReaScript API functions you are confident exist; if you are unsure, say so instead of guessing. Wrap every change in an undo block (Undo_BeginBlock / Undo_EndBlock). Quieten the UI during loops (PreventUIRefresh) and call UpdateArrange after. Add ShowConsoleMsg debug lines I can remove later. Before each script, tell me in one line what it does and how to run it.

## Organising a session

> Write a REAPER Lua script that finds every track whose name contains "gtr", colours them green, puts them in a folder called GUITARS, and routes that folder to a new bus called GTR BUS.

> Write a script that selects all tracks with no items on them and prints their names, so I can clean up an empty template.

## Rendering and deliverables

> I have a render preset called "Master WAV 24-bit". Write a script that selects that preset and renders the current time selection, naming the file after the project.

> Write a script that, after I render a WAV, calls ffmpeg to make a 320 kbps MP3 and audiowaveform to make a peaks JSON, putting all three in a folder named after the track. I am on macOS.

## Composition and MIDI

> Write a script that creates a 4-bar MIDI item on the selected track with a chord progression I give you, one chord per bar, starting at the edit cursor.

> Write a script that takes the selected MIDI notes and builds a simple arpeggio from them, up then down, in sixteenth notes.

> Write a script that adds a bassline on a new track playing the root note of each chord on the selected track, in eighth notes.

## JSFX effects

> Write a JSFX MIDI effect that locks incoming notes to a scale, with a dropdown for the root note and the scale type.

> Write a JSFX tape saturator with input gain, drive, tone and wet/dry mix, using soft clipping. Keep it efficient.

## Dialogue and podcasts

> Write a script that removes gaps of silence longer than one second from the selected items, leaving 200 ms of room either side of each cut.

> Write a script that creates a project marker at the start of every selected item, named after the item's take name.

## Working with AI music tools

> Write a script that renders the selected item to a temp WAV, runs Demucs on it from the command line to separate stems, then imports the resulting stems onto new tracks below the original. I am on macOS.

## When something breaks

> Here is the error REAPER printed: [paste it]. Fix the script and send the whole file back.
