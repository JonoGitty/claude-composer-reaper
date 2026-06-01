# Composing music as the agent (Claude makes the track)

The other references help a person script REAPER. **This one is for when the
user wants _you_ (the assistant) to actually compose and produce music for
them** — "make me a song", "build a track around this sample", "write a chiptune
loop". You do the composing; they listen and ask for changes.

This is the spine of the skill's headline use. Follow it and you can go from a
one-line brief to a finished audio file, with or without REAPER.

---

## 1. Pin down the brief (ask at most 1–2 questions)

Get just enough to commit: **genre/mood, key or feel, tempo, length, and any
reference or sample.** If the user is vague, pick sensible defaults and say what
you chose — don't stall. Good defaults: 90–110 BPM, a minor or Mixolydian key,
~60–90 s, intro → verse → chorus ×2 → outro.

If they hand you a **sample or MIDI**, analyse it first (see §2) so everything
you add fits it.

## 2. Build the harmonic scaffolding

You don't need to "feel" music to write coherent music — use theory as scaffolding.

- **Pick a key + scale.** Minor (natural/Dorian) for moody/modern; major for
  bright; **Mixolydian** (major with a flat-7) for warm/rocky/anthemic.
- **Diatonic chords** of that key, and a stock progression:
  - `i – VI – III – VII` (minor, very common, emotional)
  - `I – V – vi – IV` (major pop)
  - `I – bVII – IV` (Mixolydian, rocky/uplifting)
- **Working from a sample?** Get its pitch-class content (count which notes
  appear). The set tells you the key *and what to avoid*: e.g. a strong E–G#–B
  with a **D-natural** and no C#/D# is E Mixolydian — so harmonise with E, D, A,
  Bm (which contain D-natural) and **avoid** chords needing D# (B major, G#m),
  which would clash. Matching the sample's notes is what makes the result sound
  intentional rather than bolted-on.
- **Register/voicing:** bass roots around octave 1–2 (MIDI 28–40), chord
  voicings octave 3–4 (48–67), lead/melody octave 5 (72–84). Keep chord tones
  close; don't stack everything in one octave.

## 3. Arrange it

Think in **bars and sections**. A track is the same loop with energy added and
removed:

- Build energy with **density** (8th-note hats vs quarters), **velocity**
  (chorus louder than verse), and **adding/removing parts** (drop drums in the
  intro, full band in the chorus, strip to pad + piano in the outro).
- Mark sections so the user can navigate: intro / verse / chorus / bridge /
  outro.

## 4. Author the MIDI (don't hand-type it)

Represent every part as a list of notes:
`{pitch, start (beats), length (beats), velocity}`. Put notes at **absolute beat
positions** so each part is one clean block.

**Generate the arrays with a small script** (Python is fine) — looping bars and
emitting notes is far more accurate than typing hundreds of events by hand, and
trivial to tweak ("make the chorus busier" = change a few lines and re-emit).

**General MIDI program map** (for the offline renderer or any GM target):

| Part | GM program | Notes |
|---|---|---|
| Clean electric guitar | 27 | the Sundown-style hook |
| Acoustic/steel guitar | 25 | strummy |
| String ensemble | 48 | lush pad bed |
| Warm pad | 89/90 | synthy bed |
| Electric piano (Rhodes) | 4 | warm keys |
| Finger bass | 33 | tight low end |
| Synth bass | 38 | synthwave |
| Saw lead | 81 | cutting synth lead |
| Flute / violin | 73 / 40 | acoustic lead |

**Drums = MIDI channel 10** (index 9). Standard GM drum notes: 36 kick,
38 snare, 42 closed hat, 46 open hat, 49 crash, 51 ride, 39 clap.

## 5. Produce it — pick an output path

Three ways, choose by what's available and what the user wants back:

**A. Live in REAPER via MCP** — when the bridge is healthy and the user wants it
in their open session. Create tracks, `dsl_midi_insert` (note `start`/`length`
in **beats**; `time` as `"N bars"`), load instruments
(`track_fx_add_by_name "ReaSynth"` or the user's own VSTis — far better than
ReaSynth), set levels, `dsl_render`. **Read `07-mcp-field-notes.md` first** for
setup and the failure modes; if writes start timing out, switch to B or C
instead of fighting it.

**B. Offline, no REAPER needed** — fastest way to hand back a finished audio
file, and immune to bridge problems. Write a GM `.mid` (program changes per
channel + drums on channel 10), then:

```sh
swiftc -O scripts/render_midi_macos.swift -o render_midi_macos
./render_midi_macos song.mid song.wav            # real instruments + real kit
ffmpeg -i song.wav -af "loudnorm=I=-14:TP=-1.0,afade=t=out:st=<end-3>:d=3" final.wav
ffmpeg -i final.wav -c:a libmp3lame -b:a 320k final.mp3
```

To mix in an external audio clip (a vocal, a sampled piano), overlay it with
ffmpeg `amix` before the loudnorm pass.

**C. Author the project file** — when the user wants an **editable** REAPER
project, not just audio. Generate a `.RPP` directly (plain text: tempo, tracks,
a copied ReaSynth FX block, inline `<SOURCE MIDI>` events). They double-click it
and everything's there. See `07-mcp-field-notes.md` → "Fallback A".

## 6. Mix to taste, then master

- **Relative levels:** drums and bass forward, lead present, pad/strings back
  (−8 to −10 dB under the rest). Pan wide parts a little.
- **Master:** `loudnorm=I=-14:TP=-1.0` gets it to streaming-ish loudness without
  clipping; add a short fade-out. Bounce a 320 kbps MP3 for sharing and keep the
  WAV.

## 7. Iterate in plain English

Deliver, then take edits literally and re-run the generator: "busier chorus" →
add hats/percussion + a counter-line; "warmer lead" → swap saw (81) for EP (4)
or flute (73); "darker" → minor key / lower register; "longer" → repeat sections.
Because the parts are generated from a script, changes are seconds of work.

## Be honest about fidelity

GM/ReaSynth sounds are **demo-grade** — fine for sketches, sketches, and ideas,
not a release. For something finished, tell the user to swap in real VSTis or
live/recorded stems (path A with their own instruments, or hand them the `.RPP`
/ stems). Don't oversell a GM render as a finished production.
