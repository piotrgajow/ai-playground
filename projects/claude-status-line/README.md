# Claude status line

A two-line Claude Code status line (`claude-status-line.sh`).

```
~/work/project │ Opus 4.7 / high │ sid 1a2b3c…
tok 12.3k  $0.42 │ 5h 12% 7d 3% │ ctx 41%
```

- Line 1: working directory, model / effort, session id
- Line 2: session tokens and cost, 5h / 7d rate limits, context window usage
- Context turns yellow / red-bold at configurable percent or token thresholds; rate limits turn red at 90%

Requires `jq` (and `awk`, available by default on macOS/Linux).

## Setup

1. Install `jq` if missing (`brew install jq`).

2. Download [the script file](./claude-status-line.sh) into your home directory.

3. Run `chmod +x ~/claude-status-line.sh`

4. Add or update the `statusLine` property in `~/.claude/settings.json` (other settings are preserved; the file is created if missing):
   ```bash
   mkdir -p ~/.claude
   [ -f ~/.claude/settings.json ] || echo '{}' > ~/.claude/settings.json
   jq --arg cmd "sh $HOME/claude-status-line.sh" \
     '.statusLine = {type: "command", command: $cmd, padding: 0, refreshInterval: 1}' \
     ~/.claude/settings.json > ~/.claude/settings.json.tmp \
     && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
   ```

5. Restart Claude Code (or open a new session).

Quick check without Claude Code:
```bash
echo '{"model":{"display_name":"Test"},"cwd":"'"$HOME"'"}' | sh ~/claude-status-line.sh
```

## Updating

Re-run step 2 to get the latest script.

## Customising

Edit the tunables at the top of the script (`CTX_*` thresholds, `LIMIT_WARN_PCT`).
