# MCP field notes: what actually happens when you let an agent drive REAPER

Reference 03 explains the *idea* of agent control. This file is the *reality* —
notes from real sessions building songs through a live MCP bridge, including the
ways it falls over and how to recover. Read this before a long session and you
will save yourself an hour of confusion.

The setup these notes are based on:

- **REAPER 7.x** on macOS.
- **MCP server:** `shiehn/total-reaper-mcp`, registered with Claude Code.
- **Bridge:** a Lua script (`mcp_bridge_file_v2.lua`) that runs *inside* REAPER
  and talks to the server through files in a `mcp_bridge_data/` folder
  (`request_*.json` in, `response_*.json` out).
- Tools exposed as `dsl_*` (friendly: `dsl_track_create`, `dsl_midi_insert`,
  `dsl_render`, …) plus lower-level ReaScript calls.

Other servers differ in detail, but the bridge-inside-REAPER pattern and its
failure modes are broadly the same.

---

## The one-paragraph mental model

The agent never touches REAPER directly. It writes a request file; the bridge
script, running on REAPER's **main thread** inside a timer/defer loop, reads the
file, calls the ReaScript API, and writes a response file. Two things follow
from this, and they explain almost every problem below:

1. **If REAPER's main thread is blocked, every write hangs.** A modal dialog
   (Save As, "save changes?", "ReaScript task control") freezes the main thread,
   so the bridge can't run API calls. Reads that return cached state may still
   answer; anything that modifies the project times out.
2. **If the bridge's loop stops, nothing happens at all.** Closing a project
   tab terminates running ReaScripts — including the bridge. The request files
   just pile up unread.

---

## What works well (the happy path)

When REAPER is freshly open with **one** project, **one** tab, and the bridge
loaded **once**, it's genuinely good. In a clean session we built a full
multitrack song in seconds: set tempo, created tracks, wrote MIDI, loaded
instruments, balanced levels, rendered to WAV. Operations came back in ~100 ms.

Concrete things that work, with their quirks:

- **`dsl_set_tempo` / `dsl_track_create` / `dsl_track_volume`** — fine. Volume
  accepts `"-6dB"`, `"+3"`, linear, etc.
- **`dsl_midi_insert`** — the workhorse for writing notes. Two quirks worth
  knowing:
  - The `time` argument wants a phrase like `"8 bars"`. A range like `"0-8"` is
    rejected with *"Cannot parse time"*.
  - Note `start`/`length` are in **beats** (quarter notes), relative to the
    item start. Put notes at absolute beat positions and pass a `time` long
    enough to cover them, and you get one clean item per track — no need to
    position the cursor.
  - Inserting onto a track twice makes a *second, overlapping* item. Delete and
    recreate the track if you want a clean slate.
- **`track_fx_add_by_name "ReaSynth"`** — loads REAPER's built-in synth so MIDI
  tracks make sound immediately. Note: there is **no drum kit** in stock
  REAPER, so a "Drums" track on ReaSynth is tuned blips. Point it at a real
  drum sampler, or render drums elsewhere (see reference 07b / the offline
  renderer).
- **`dsl_render`** — bounces the project to audio. Writes next to the project
  file.

Things to avoid:

- **`dsl_generate` is paywalled.** The AI-generation tools return a "Premium
  Feature … please log in" message. Don't rely on them; write the MIDI yourself
  (the agent is perfectly capable of composing note arrays).

---

## How it falls over (and why)

Every one of these we hit for real. Symptoms first, then cause.

| Symptom | Cause |
|---|---|
| Writes hang ~5 s then "Timeout waiting for REAPER response", reads still work | REAPER main thread blocked by a modal dialog |
| Everything dead, request files pile up unread in `mcp_bridge_data/` | Bridge loop stopped (project was closed, which kills running ReaScripts) |
| `dsl_save` with a name freezes the bridge | It opened a **Save As** dialog (modal) |
| Tempo suddenly reads 120 and tracks "vanish" | Focus jumped to a different / new **project tab** |
| "No tracks found matching X" right after creating X | Track was created in one **tab**, the read queried another |
| Several concurrent `dsl_track_create` calls but not all tracks appear | They each `InsertTrackAtIndex(0)` at once and **race**; create sequentially |
| Re-running the bridge action makes it worse | Spawns a "ReaScript task control" dialog and/or a **second instance** racing for the same files |

The throughline: the bridge is fragile to **modal dialogs**, **project
lifecycle events** (open/close/save), **multiple instances**, and **multiple
tabs**. None of these are the agent's doing — they come from clicking around in
REAPER while a session is live.

---

## Reliable setup (do this every time)

1. Open REAPER. Make sure there is exactly **one project** and **one tab**.
2. Load the bridge **once** (Actions → Show action list → run the bridge script,
   or Load ReaScript from the file picker). Wait for the console line
   `… Bridge … started`. **Don't run it again.**
3. **Health check before building:** ask the agent to create a temp track and
   delete it. If that round-trips in ~100 ms, you're good. If it times out,
   recover (below) before doing anything else.
4. During the session, **don't** open/close/save other projects, switch tabs,
   or open modal windows (FX browser left open, render dialog, etc.).
5. Save **once, at the end.** Expect the Save dialog may need a manual click —
   handle it, then stop.

### Make it painless: auto-load the bridge

The single biggest friction is "load the bridge by hand every launch", and
re-loading it is what spawns duplicate instances. Remove the manual step:

- Put a loader in REAPER's **`__startup.lua`** (in the Scripts folder) that runs
  the bridge once when REAPER opens, **or** add the bridge action to SWS's
  *Startup actions*. Then it's always running, exactly once, and you never touch
  it.

---

## Recovery playbook (when writes start timing out)

Work down this list; stop as soon as a health-check write succeeds.

1. **Clear modal dialogs.** Look hard for a small window — especially
   *"ReaScript task control"* (choose **New instance**, not Terminate) and
   *"Save changes?"*. One open dialog freezes everything.
2. **One tab only.** Close extra project tabs (don't save) until one remains.
3. **Clear stale IPC files:**
   `rm "<REAPER resource>/Scripts/mcp_bridge_data/"request_*.json response_*.json`
4. **Full restart.** Quit REAPER (force-quit if needed), reopen, load the bridge
   **once**, health-check.
5. **If writes still time out after a clean restart**, the live path is a dead
   end for this session. Switch to a fallback — don't keep restarting.

A quick way to confirm the bridge loop is alive vs dead: watch
`mcp_bridge_data/`. If your commands leave `request_*.json` files sitting there
unconsumed, the loop is dead (step 4). If files appear and vanish but the call
still times out, REAPER's main thread is blocked (steps 1–2).

---

## Fallbacks that don't need the bridge

When the bridge won't cooperate, you can still deliver. Both of these were used
to finish a song after the live path failed.

### Fallback A — author the `.RPP` directly

A REAPER project file is **plain text**. An agent can generate a complete,
playable project on disk; you just double-click it. This is 100% reliable
because it never touches the bridge.

What you need to get right:
- `TEMPO 140 4 4`, markers, one `<TRACK>` block per part.
- **Instrument:** copy a `<VST … ReaSynth …>` block (with its base64 state)
  verbatim out of any project REAPER has saved with ReaSynth on a track. Give
  each track a fresh `FXID`/`TRACKID` GUID.
- **MIDI:** inside an `<ITEM>`, a `<SOURCE MIDI>` block with `HASDATA 1 960 QN`
  and event lines `E <delta-ticks> <status> <d1> <d2>` (hex, 960 ticks per
  beat; `90`=note on, `80`=note off, ending `E 0 b0 7b 00`).
- **Audio item:** `<SOURCE MP3>` / `<SOURCE WAVE>` with `FILE "/abs/path"`.

Tip: save a tiny project from REAPER first and read it as your template — the
syntax is finicky and a real file removes the guesswork.

### Fallback B — render MIDI to real-instrument audio, offline

You don't need REAPER (or any download) to turn MIDI into audio that sounds
like real instruments. macOS ships a General MIDI soundbank
(`gs_instruments.dls`, the GarageBand/QuickTime synth). `fluidsynth` can't read
`.dls` and fetching an `.sf2` is often blocked on locked-down machines — so use
CoreAudio's DLS synth directly.

`scripts/render_midi_macos.swift` does exactly this: it loads a GM MIDI file,
plays it through the Apple DLS synth offline, and writes a WAV — multi-timbral,
with a **real drum kit** on channel 10. Then master with ffmpeg:

```sh
swiftc -O scripts/render_midi_macos.swift -o render_midi_macos
./render_midi_macos song.mid song.wav
ffmpeg -i song.wav -af "loudnorm=I=-14:TP=-1.0,afade=t=out:st=68:d=3" final.wav
```

Write the MIDI as a normal GM file: program changes per channel (e.g. clean
guitar, strings, finger bass, a synth lead) and drums on channel 10. You get a
finished band mix without REAPER in the loop at all.

---

## TL;DR

- Live MCP control is great **when REAPER is clean**: one project, one tab,
  bridge loaded once, no dialogs, no clicking around.
- Most failures are environmental (dialogs, tab switches, closed projects,
  duplicate bridge instances), not the agent's fault. The recovery playbook
  fixes the common ones; a clean restart fixes most of the rest.
- Auto-load the bridge from `__startup.lua` to kill the worst friction.
- Always have a fallback: author the `.RPP` directly, or render MIDI offline
  through the macOS GM synth. Both ship in this repo.
