# Preparing sound pack

## Create work directories

main: e.g. Game > Character >
- `examples`
  - `raw`
  - `norm`
- `output`
- `voice`
  - `clear`
  - `eror`
  - `finished`
  - `goodbye`
  - `hello`
  - `idle`
  - `request`
  - `resume`

## Generate texts

### Create input

`input.md` file with skill input: short description (who from what game) + list of quotes to analyze (link to wiki, text)

### Run skill

Run the `/generate-voice-lines` skill with the input passed as arguments

### Save output

Save the generated lines into `lines.md`

## Prepare samples

### Select sound files

Download sound files for samples and that should be reused to `examples/raw`.

### Reusing

Extract files to be reused into proper directories within `voice`. Trim and convert to mp3 with Audacity when needed.

### Prepare sample for ElevenLabs

Run `_util/process.sh <path>`. The script should produce `.mp3` files (up to 10 MB each) in the `examples` directory.

## Generate audio files

### Create voice in ElevenLabs

Upload the sample files to create voice.

### Create lines audio

Convert `lines.md` into regular text `lines.txt`:
- remove headings
- remove reused lines
- remove line numbers
- remove quotation marks

Pass the text to ElevenLabs, generate audio, download the file to `output/` directory.

### Split into voice line files

Extract voice lines into separate mp3 files with Audacity and put them in the directories.

# Audacity - extract to mp3

- Open file
- Select part of the audio
- Export Audio `Shift + Cmd + E`
- MP3, Mono, 44100 Hz, Preset, Standard, Current selection, Trim blank space
