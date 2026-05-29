# claude-composer-reaper

A head start for using **Claude Code** (or any coding agent) with **REAPER**, the DAW.

REAPER is one of the most open DAWs there is. Almost everything it does can be scripted, its project files are plain text, and it happily talks to outside tools. That makes it a great fit for an AI coding assistant: you describe a boring or fiddly job in plain English, the assistant writes the script, and you run it inside REAPER.

This repo is built for people who **know music and audio well but are new to coding**. You do not need to understand the code to get value out of it. You run the starters, you describe what you want, the assistant does the typing.

It ships as a Claude skill plus a small library of working starter scripts and a curated set of references.

## What is inside

```
SKILL.md                  the skill itself (Claude reads this)
reference/                plain-English guides, one per workflow
scripts/                  working Lua ReaScripts you can run today
jsfx/                     a starter JSFX effect
prompts/                  copy-paste prompts that get good results
```

References:

- `01-getting-started.md` - install REAPER, find the Scripts folder, run your first script, point Claude Code at it
- `02-scripting-with-claude.md` - the everyday loop: describe a task, get a Lua script, run it, paste errors back
- `03-agent-control-mcp.md` - let an agent control REAPER live through an MCP server (the new frontier)
- `04-jsfx-effects.md` - build your own effects and MIDI tools in JSFX, REAPER's built-in effect language
- `05-music-ai-toolkit.md` - stem separation, mastering, hum-to-MIDI, AI vocals and where they slot into REAPER
- `06-from-mix-to-release.md` - turn a finished mix into release files (WAV, MP3, waveform data) with one script

## Install

### Option A: as a Claude Code skill (recommended)

```bash
git clone https://github.com/JonoGitty/claude-composer-reaper.git
mkdir -p ~/.claude/skills
cp -R claude-composer-reaper ~/.claude/skills/claude-composer-reaper
```

Then in Claude Code, just ask in plain English: "help me write a REAPER script that..." and the skill kicks in. Or type `/claude-composer-reaper` if you want to load it explicitly.

### Option B: just use the files

You do not need the skill machinery. Clone the repo, read the references, and copy any script in `scripts/` straight into REAPER.

## Run your first script in two minutes

1. In REAPER: `Options > Show REAPER resource path in explorer/finder`. The `Scripts` folder is in there.
2. Copy `scripts/01_hello_list_tracks.lua` into that `Scripts` folder.
3. In REAPER: `Actions > Show action list > New action > Load ReaScript`, pick the file, and run it.
4. A console window prints every track in your project. That is ReaScript working.

From there, read `reference/02-scripting-with-claude.md` and start asking the assistant for the tools you actually want.

## The one rule

Save a copy of your project before you run a new script on real work. Scripts make real edits. Every script here wraps its changes in a single undo step, so one Ctrl+Z reverses it, but a backup is cheap insurance.

## Why REAPER

It is small, fast, scriptable in Lua, EEL2 and Python, has a built-in effect language (JSFX), a documented C++ extension SDK, and a huge community script library (ReaPack, SWS). The license is honest and cheap. If you want a DAW you can shape around your own workflow with an AI assistant, this is the one.

## License

MIT. See `LICENSE`. Do what you like with it.

## Credits

REAPER is made by Cockos. This project is not affiliated with or endorsed by Cockos. It only uses the public ReaScript API and the public extension SDK.
