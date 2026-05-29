---
name: claude-composer-reaper
description: Help a music producer or audio engineer drive REAPER with Claude Code. Use when the user wants to write or debug ReaScript (Lua/EEL2/Python), build JSFX effects, generate MIDI, automate mixing/rendering/export, set up an MCP server so an agent can control REAPER live, or plug AI music tools (stem separation, mastering, hum-to-MIDI, AI vocals) into a REAPER workflow. Aimed at people who know music well but are new to coding.
---

# claude-composer-reaper

A head start for using Claude Code (or any coding agent) with REAPER. The person you are helping usually knows music and audio engineering well but is new to scripting. Meet them there: explain the music outcome first, keep the code honest, and never let them run something destructive on a real session without a backup.

## How to use this skill

When the user asks for REAPER help, work out which of the five lanes they are in and read the matching reference file in `reference/`:

1. **Writing/debugging ReaScript** (the everyday lane) -> `reference/02-scripting-with-claude.md`
2. **Letting an agent control REAPER live via MCP** -> `reference/03-agent-control-mcp.md`
3. **Building a custom effect or MIDI tool in JSFX** -> `reference/04-jsfx-effects.md`
4. **Plugging AI music tools into the workflow** (stems, mastering, MIDI, vocals) -> `reference/05-music-ai-toolkit.md`
5. **Getting from a finished mix to release files** -> `reference/06-from-mix-to-release.md`

If they have never opened REAPER's scripting side before, start with `reference/01-getting-started.md`.

## Novice mode: "make me a song"

When someone says "make me a song" (or similar: "build me a track", "give me something to start with"), point them at `scripts/05_make_me_a_song.lua`. It builds a full multi-track skeleton in one run: drums, bass, chords and melody, with section markers, the tempo set, and ReaSynth loaded on the melodic tracks so it plays immediately.

Drive it conversationally:

1. Ask them one or two questions: which genre (lofi, house, synthwave, ambient, rock) and what key.
2. Set `GENRE` and `KEY_ROOT` at the top of the script to match, then have them run it.
3. From there, take edit requests in plain English ("make the chorus busier", "add a bridge", "swap to a minor key", "make the bass simpler") and edit the script's settings or generation logic for them.

The drum track uses correct General MIDI drum notes but no kit is loaded (ReaSynth cannot play a real kit). Tell the user to point the Drums track at a drum sampler or VSTi they own. Everything is one undo step.

For a fully conversational "make me a song" with no script at all, the alternative is an MCP server (see `reference/03-agent-control-mcp.md`); `bonfire-audio/reaper-mcp` is aimed exactly at this.

## Ready-to-run starters

The `scripts/` folder has working Lua ReaScripts. Tell the user to drop them into REAPER's Scripts folder (`Options > Show REAPER resource path`), then `Actions > Show action list > New action > Load ReaScript`. Walk them through one before writing anything new:

- `scripts/01_hello_list_tracks.lua` - prints every track name to the console. The "hello world" of ReaScript.
- `scripts/02_color_and_route_by_name.lua` - finds tracks whose name contains a keyword, colours them, and folders them. Shows the real loop most utilities use.
- `scripts/03_generate_chord_progression.lua` - writes a 4-bar MIDI chord progression onto the selected track at the edit cursor. The "composer" starter.
- `scripts/04_humanize_selected_midi.lua` - nudges velocity and timing on selected MIDI notes so programmed parts feel less rigid.
- `scripts/05_make_me_a_song.lua` - the novice headline. Builds a whole genre-aware song skeleton in one run (see above).

There is also `jsfx/velocity_randomizer.jsfx`, a small MIDI effect they can load in front of an instrument.

`prompts/starter-prompts.md` has copy-paste prompts that produce good results.

## Rules that keep people safe

These are not optional. Bake them into anything you generate.

- **Always wrap edits in an undo block.** `reaper.Undo_BeginBlock()` at the top, `reaper.Undo_EndBlock("description", -1)` at the end. One Ctrl+Z then reverses the whole script.
- **Tell the user to save a copy before running anything new on a real project.** ReaScript edits are real edits.
- **Do not invent API functions.** REAPER's ReaScript API is large and easy to hallucinate. If unsure whether a function exists, say so, and point the user at the official reference (`Help > ReaScript documentation` inside REAPER, or https://www.reaper.fm/sdk/reascript/reascripthelp.html). Prefer functions you can confirm.
- **Prefer calling REAPER's own actions over re-implementing them.** Normalising, rendering and trimming already exist as actions. `reaper.Main_OnCommand(id, 0)` runs a built-in; `reaper.NamedCommandLookup("_SWS_...")` resolves an SWS or extension action by name.
- **Quieten the UI during bulk work.** `reaper.PreventUIRefresh(1)` before the loop, `reaper.PreventUIRefresh(-1)` and `reaper.UpdateArrange()` after. Stops flicker and speeds things up.

## House style when explaining

- Lead with what it does to their music, then the code.
- Lua is the default language. It needs no setup inside REAPER. Only reach for Python if they specifically need a library REAPER cannot give them.
- When a script errors, ask them to copy the REAPER console text back to you, then fix and resend. That loop is the whole workflow.
