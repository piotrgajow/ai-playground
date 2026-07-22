#!/bin/zsh

setopt null_glob
set -e

BITRATE=128
MAX_MB=10
GAP=0.4
BPS=$(( BITRATE * 1000 / 8 ))
MAX_SEC=$(( MAX_MB * 1024 * 1024 * 92 / 100 / BPS ))

cd "${0%/*}"
SILENCE="$(PWD)/silence.wav"
cd "../$1/examples"

# Normalize
echo 'Normalizing samples'

i=0
for f in ./raw/*.(mp3|wav|m4a|flac|aac|ogg|opus|MP3|WAV|M4A); do
  i=$(( i + 1 ))
  out=$(printf "./norm/%04d.wav" $i)
  ffmpeg -v error -y -i "$f" \
    -af loudnorm=I=-18:TP=-2:LRA=11 \
    -ar 44100 -ac 1 -c:a pcm_s16le "$out"
done

# Chunks by duration
echo 'Splitting by duration'

chunk=1
acc=0
list=$(printf "./list_%03d.txt" $chunk)
: > "$list"

for f in ./norm/*.wav; do
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
  dur_i=${dur%%.*}

  if (( dur_i > MAX_SEC )); then
    echo "    !! ${f:t} is ${dur_i}s, alone exceeds the budget - split it manually"
  fi

  if (( acc > 0 && acc + dur_i > MAX_SEC )); then
    chunk=$(( chunk + 1 ))
    acc=0
    list=$(printf "./list_%03d.txt" $chunk)
    : > "$list"
  fi

  echo "file '$f'" >> "$list"
  echo "file '$SILENCE'" >> "$list"
  acc=$(( acc + dur_i + 1 ))
done

# Generate files
echo 'Generating samples'

for list in ./list_*.txt; do
  n=${${list:t:r}#list_}
  out="./sample_${n}.mp3"
  ffmpeg -v error -y -f concat -safe 0 -i "$list" \
    -c:a libmp3lame -b:a ${BITRATE}k -ar 44100 -ac 1 "$out"
done

echo 'Done'
