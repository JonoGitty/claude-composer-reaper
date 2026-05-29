# Getting started

This is for someone who has REAPER installed (or is about to) and has never touched its scripting side. By the end you will have run a script and know where everything lives.

## 1. Get REAPER

Download it from https://www.reaper.fm. The trial is full-featured and does not expire in a way that blocks you while you learn. A license is cheap if you keep using it.

## 2. Find the resource path

Everything scriptable lives under one folder. In REAPER:

`Options > Show REAPER resource path in explorer/finder`

A file window opens. The folders that matter:

- `Scripts/` - your ReaScripts go here
- `Effects/` - your JSFX effects go here
- `UserPlugins/` - compiled C++ extensions go here

## 3. Install ReaPack and SWS (do this once)

Two community add-ons that almost everyone uses. You will see them mentioned everywhere.

- **ReaPack** (https://reapack.com) is a package manager for REAPER scripts and effects. Install it, restart REAPER, and you can pull thousands of community tools from inside the app.
- **SWS / S&M Extension** (https://www.sws-extension.org) adds hundreds of extra actions and API functions. A lot of scripts assume it is present.

Neither is required to run the starters in this repo, but both make life easier later.

## 4. Run your first script

1. Copy `scripts/01_hello_list_tracks.lua` from this repo into the `Scripts/` folder you found in step 2.
2. In REAPER: `Actions > Show action list`.
3. Click `New action > Load ReaScript`, choose the file, and it appears in the list.
4. Select it and click `Run`.

A console window appears listing every track in your project. If your project is empty, add a couple of tracks first so you see something.

That is the whole mechanism. A script is a text file in `Scripts/`, loaded as an action, run from the action list. You can later bind it to a keyboard shortcut or a toolbar button.

## 5. Point Claude Code at the folder

This is where it gets fun. Open the `Scripts/` folder as a project in Claude Code (or Cursor):

```bash
cd "/path/to/REAPER/Scripts"
git init        # optional but smart: version your scripts
```

Now you can ask the assistant to write a script, it lands in the folder, and you reload it in REAPER. The loop in `reference/02-scripting-with-claude.md` covers this properly.

## A note on the three languages

REAPER scripts can be written in three languages:

- **Lua** - the default. No setup, easy to read, what this repo uses. Start here.
- **EEL2** - REAPER's own tiny language. Fast, a bit cryptic. Fine for small jobs.
- **Python** - works, but needs a Python install configured in REAPER's preferences. Only worth it when you need a Python library REAPER cannot provide.

Stick with Lua unless you have a clear reason not to.
