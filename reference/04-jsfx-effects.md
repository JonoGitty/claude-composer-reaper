# Building effects and MIDI tools in JSFX

JSFX is REAPER's built-in effect language. You write a plain text file, drop it in the `Effects/` folder, and it shows up in the FX browser as a real plugin. There is no compiler and no build step, so the write-test loop is fast. That makes it the best place to prototype custom effects and MIDI tools with an AI assistant.

## What JSFX is good for

It will not replace a top commercial saturator, but it is excellent for:

- MIDI tools: velocity randomisers, note humanisers, scale lockers, arpeggiators, chord triggers
- Simple audio effects: gain utilities, saturators, delays, stereo wideners, basic filters
- Meters and analysis tools
- Weird creative one-offs you cannot buy

Because there is no build step, you can ask the assistant for an effect, save it, and hear it in seconds.

## The loop

1. Ask the assistant for a JSFX effect, describing the musical behaviour.
2. It writes a `.jsfx` file. Save it into REAPER's `Effects/` folder.
3. In REAPER, add it to a track from the FX browser (rescan or restart if it does not appear).
4. Tweak the sliders. If it misbehaves, paste any error back and iterate.

## The shape of a JSFX file

Every JSFX has named sections. You do not need to memorise this, but recognising it helps you read what the assistant gives you:

```
desc:My Effect            // the name shown in REAPER

slider1:8<0,32,1>Amount   // a control: default 8, range 0 to 32, step 1

@init                     // runs once when the effect loads
@slider                   // runs when a slider moves
@block                    // runs every audio block (where MIDI is handled)
@sample                   // runs for every audio sample (where audio is processed)
```

There is a working MIDI example in `jsfx/velocity_randomizer.jsfx` in this repo. Load it in front of a virtual instrument and it humanises incoming note velocities.

## Good first asks

- "Write a JSFX MIDI effect that randomises incoming note velocity by plus or minus a slider amount, without changing pitch or timing."
- "Write a JSFX that locks incoming MIDI notes to a chosen scale, with a dropdown for the root note."
- "Write a JSFX tape-style saturator with input gain, drive, tone and a wet/dry mix, using soft clipping."
- "Write a JSFX stereo width control with a mono-below-frequency option to keep the bass centred."

## A caution

An AI-written audio JSFX can sound wrong or be inefficient even when the code runs. Trust your ears, not the fact that it compiled. For MIDI tools the risk is lower because the logic is simpler. Start with MIDI effects to get comfortable, then move to audio.

## Where JSFX fits next to plugins

JSFX lives alongside your VST and AU plugins in the same FX chain. You can put an AI-written MIDI humaniser in front of Kontakt, or a custom utility after a commercial compressor. It is not a separate world, it is just more plugins, ones you can open and change.
