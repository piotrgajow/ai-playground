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

# Volume control

Playback volume is read from `~/.cache/piotrgajow-sounds/volume` on every sound. The value is a linear multiplier passed to `afplay -v` (`1` = normal, `0.5` = quieter, values above `1` amplify). If the file is missing or does not contain a valid number, sounds play at the default volume (`1`). Changes take effect on the next sound - no restart of Claude Code needed.

## Installing the `claude-sounds-volume` command

Add the following code to your `~/.zshrc`:

```bash
# Adjust the playback volume of piotrgajow-sounds notifications.
claude-sounds-volume() {
  local file="${HOME}/.cache/piotrgajow-sounds/volume"
  if [[ $# -eq 0 ]]; then
    if [[ -f "$file" ]]; then
      echo "Current volume: $(cat "$file")"
    else
      echo "Current volume: not set (defaults to 1)"
    fi
    return 0
  fi
  local valid_number='^[0-9]*\.?[0-9]+$'
  if [[ ! "$1" =~ $valid_number ]]; then
    echo "Usage: claude-sounds-volume [<number>]" >&2
    echo "  <number>  volume multiplier, e.g. 0.5 (1 = normal)" >&2
    return 1
  fi
  mkdir -p "${file:h}"
  printf '%s\n' "$1" > "$file"
  echo "Volume set to $1"
}

```

```bash
claude-sounds-volume        # show current volume
claude-sounds-volume 0.5    # set volume to 50%
claude-sounds-volume 1      # back to normal volume
```
