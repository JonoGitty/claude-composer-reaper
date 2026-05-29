# From mix to release files

A finished mix is not finished until it is in the formats you need: a lossless master, an MP3 for sharing, and increasingly some metadata or waveform data for a website. This is exactly the kind of repetitive job to hand to a script and a button.

## The deliverables most people need

- **WAV** (or FLAC) at full quality, the lossless master.
- **MP3** at 320 kbps for email, messaging, and quick listening.
- Sometimes a **waveform data file** (a JSON list of amplitude peaks) so a website can draw the track's waveform without loading the whole audio file.

Doing this by hand every release is dull and error-prone. A script does it the same way every time.

## Rendering in REAPER

REAPER's render dialog (`File > Render`) is powerful and a little fiddly. The reliable way to script renders is to set up your render settings once, save them as a render preset, and have the script select that preset and run the render action. Trying to set every render field from script is brittle; presets are not.

A practical pattern:

1. In REAPER, configure a render preset for "Master WAV 24-bit" and another for "Share MP3 320".
2. Ask the assistant for a script that selects a preset and renders the current time selection or project, naming the output after the project or a region.
3. Run it once per format, or chain them.

Because render configuration is the finicky part, expect a round or two of fixing with the assistant. Paste any console output back.

## MP3 and waveform data outside REAPER

For the MP3 and the waveform file, the simplest reliable route is two small command-line tools the assistant can call:

- **ffmpeg** converts a WAV to a 320 kbps MP3 in one command.
- **audiowaveform** (a free tool from the BBC) generates a peaks JSON from an audio file, ready for a website waveform display.

Ask the assistant to write a script that, after the WAV master is rendered, runs ffmpeg to make the MP3 and audiowaveform to make the peaks file, all named consistently and dropped in one folder. That gives you a single command that turns a finished mix into a complete release bundle.

## Why this is worth scripting

If you put music online, this is the bridge between your DAW and your site. Render the master, get the MP3 and the waveform data automatically, upload. One button instead of ten manual steps, and no forgotten format or wrong bitrate. It is the clearest example in this whole repo of the assistant saving real time on real work.

## A sketch of the full chain

```
finished mix in REAPER
   -> render preset: Master WAV 24-bit  (script runs the render action)
   -> ffmpeg: WAV -> MP3 320            (script calls ffmpeg)
   -> audiowaveform: WAV -> peaks.json  (script calls audiowaveform)
   -> all three files in /release/<track-name>/
```

Ask the assistant to build this for your operating system and your folder layout. It is a great second or third project once you are comfortable running scripts.
