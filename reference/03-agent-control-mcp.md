# Letting an agent control REAPER live (MCP)

> **Before a real session, read `07-mcp-field-notes.md`.** This file covers the
> concept; 07 covers what actually happens — the failure modes (stalled bridge,
> modal dialogs, duplicate instances, multiple project tabs), a reliable setup
> and recovery playbook, and bridge-free fallbacks for when it won't cooperate.

The newest way to combine REAPER with an AI assistant is to let the assistant control REAPER directly while you watch. You say "build me a drum bus and route the kit into it" and the tracks appear in your open project. This works through something called MCP.

## What MCP is, in one paragraph

MCP (Model Context Protocol) is a standard way for an AI assistant to call tools on your computer. An MCP server is a small program that exposes a set of actions ("create track", "set volume", "add marker", "render"). The assistant calls those actions, the server passes them to REAPER, and REAPER does them. You stay in the chair the whole time and approve what happens.

The shape of it:

```
You talk to Claude / Cursor
        |
        v
MCP server (a small program on your machine)
        |
        v
REAPER (your open project)
```

## The community servers

Several people have already built REAPER MCP servers. These are real, public projects (star counts are a rough popularity signal, not a quality guarantee, and they move over time). Check each repo's README for current setup steps, because they change.

- **shiehn/total-reaper-mcp** - aims for full coverage of REAPER's ReaScript API, so the assistant can reach almost anything.
- **bonfire-audio/reaper-mcp** - focused on production: the assistant can build, mix and master tracks, with both MIDI and audio.
- **dschuler36/reaper-mcp-server** - a general server for working with REAPER projects.
- **wegitor/reaper-reapy-mcp** - Python-based, built on the reapy library.
- **xDarkzx/Reaper-MCP** - a large toolset aimed at composition, MIDI, FX, mixing and mastering.

Search GitHub for "reaper mcp" to see the current field before you pick one.

## How to try it

The exact steps depend on the server you choose, but the pattern is the same:

1. Install the server (most are a `git clone` plus an install command from their README).
2. Most servers also need a small bridge script running inside REAPER that listens for commands. The README will tell you where it goes.
3. Register the server with your assistant. In Claude Code this is an entry in your MCP config. The repo's README usually gives you the exact block to paste.
4. Open a project in REAPER, start a chat, and ask for something small first ("list my tracks") to confirm the link works.

## Good first asks

Start small and non-destructive, then build up:

- "List the tracks in my open project and their volumes."
- "Create a folder called DRUMS with child tracks Kick, Snare, OH L, OH R, and route them to a new DRUM BUS."
- "Add markers for Intro, Verse, Chorus and Bridge at bars 1, 9, 25 and 41."
- "Make a basic mix template for a four-piece band: drums folder, bass, two guitars, lead vocal, plus reverb and delay return tracks. Colour-code them."

## Safety with agent control

An agent that can edit your session can also break it. Keep these habits:

- Work on a copy of important projects while you are learning what a server does.
- Ask the agent to describe its plan and wait for your yes before it changes anything, especially deletions.
- Prefer servers that report what they did, so you can check.
- Save versions often. REAPER's `File > Save new version` is one keystroke.

## When to use this versus plain scripting

Plain scripting (reference 02) is best for a repeatable job you will run many times: render deliverables, clean dialogue, organise a session the same way every time. Bind it to a button and forget it.

Live agent control is best for one-off, interactive shaping: "set this session up", "suggest routing changes", "build me a template for this genre". It can inspect the current project and react, which a fixed script cannot.

Most people end up using both.
