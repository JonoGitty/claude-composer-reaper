# AI music toolkit around REAPER

REAPER is the hub. Most AI music tools live outside it and feed material in, or run inside it as plugins. This is a map of what people actually use and where it slots into a REAPER session. Tool names and prices change, so treat this as a starting list, not gospel.

## Stem separation

Split a finished stereo track into vocals, drums, bass and other parts. Useful for remixing, practice, karaoke, sampling, or studying a groove.

- **Ultimate Vocal Remover (UVR)** - free desktop app, very popular, several models to choose from.
- **Demucs** - open-source, command-line, strong quality. Good for automating from a script.
- **iZotope RX Music Rebalance** and **Steinberg SpectraLayers** - paid, integrated, higher polish.

Workflow: separate the track, then drag the stems into REAPER, line them up at bar 1, put them in a folder, and group them so edits stay aligned. Expect some artefacts; high-pass and transient shaping help hide them.

You can automate this: a ReaScript renders the selected item to a temp file, calls Demucs on it, and imports the resulting stems onto new tracks. Ask the assistant to write that glue script for your operating system.

## Mastering

Get a mix to release loudness with tonal balance.

- **iZotope Ozone** with its Master Assistant - the common paid choice, runs as a plugin on your master.
- **Matchering** - open-source, matches your track to a reference you provide. Free and scriptable.
- **Sonible smart:limit** - paid, assistant-driven limiter.

Workflow: render your mix with headroom (peaks around -6 to -3 dBFS, no limiter on the master), open it in a fresh REAPER project, build a mastering chain, run the assistant, then back off anything too aggressive and compare to references.

## Composition and MIDI

- **Hum-to-MIDI**: Spotify's **Basic Pitch** turns a sung or hummed melody into MIDI. Sing an idea into REAPER, convert, drop the MIDI back on a synth. Great if you do not play keys.
- **Chord and melody helpers**: **Scaler 2**, **Captain Plugins**, **Orb Producer Suite** generate progressions and melodies as plugins. Route their MIDI to an instrument track and record it.
- **Script-generated MIDI**: ask the assistant for a Lua script that writes a chord progression or drum pattern straight into REAPER. There is a starter in `scripts/03_generate_chord_progression.lua`.

## AI vocals

- **Synthesizer V** and **ACE Studio** - give them a melody and lyrics, get a sung vocal back. Render to audio, import to REAPER, mix like any vocal.
- Use cases: demo vocals, harmony layers, topline sketches before a real singer.

## Cleanup and dialogue

REAPER is heavily used for podcasts and audiobooks, and AI cleanup tools are strong here.

- **iZotope RX**, **Waves Clarity Vx**, **Supertone Clear**, **Adobe Enhance Speech** for denoise, de-reverb and voice repair.
- Pair with an AI-written ReaScript that removes long silences, adds chapter markers, and renders each segment.

## Guitar and bass

- **Neural Amp Modeler (NAM)** and **IK Multimedia TONEX** load amp captures so a DI guitar sounds like a real rig inside REAPER.

## Where the coding assistant helps most

The assistant is least useful as a "make me a song" button and most useful as the glue between these tools and REAPER:

- writing the script that exports an item, runs Demucs, and reimports stems
- writing the render script that produces your exact deliverables
- generating MIDI utilities and JSFX MIDI effects
- writing a dialogue-cleanup automation for a repeatable podcast workflow

Let the AI handle the repetitive plumbing and the option-generation. Keep the taste and the final call with yourself.
