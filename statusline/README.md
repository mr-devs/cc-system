# Claude Code Statusline

A custom statusline script for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that displays real-time usage information directly in the terminal.

Reference: https://alexop.dev/posts/customize_claude_code_status_line/

## What it shows

- **Model** — the active Claude model name
- **Working directory** — your current path
- **Context window** — percentage of the context window used in the current conversation
- **Session limit** — 5-hour rolling usage with a countdown timer to reset
- **Weekly limit** — 7-day rolling usage with the next reset date/time in local time

Each metric is rendered as a color-coded progress bar:
- Green: < 50%
- Yellow: 50–79%
- Red: 80%+
- Bold red: weekly usage above the configurable `LOW_BALANCE_THRESHOLD` (default 90%)

## Requirements

- macOS (uses `security` for Keychain access and BSD `date`/`stat`)
- `jq`
- An active Claude Code OAuth session (credentials stored in the macOS Keychain)

## Setup

1. Copy `statusline.sh` to `~/.claude/statusline.sh` (or any path you prefer).
2. Make it executable: `chmod +x ~/.claude/statusline.sh`
3. Configure Claude Code to use it by adding the following to `~/.claude/settings.json`:

```json
{
  "statusline": {
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

## How it works

The script reads a JSON payload from Claude Code via stdin containing the current model and context window usage. It then fetches session and weekly usage data from the Anthropic API using the OAuth token stored in the macOS Keychain. API responses are cached to `/tmp/claude_usage_cache.json` for 5 minutes (configurable via `CACHE_TTL`) to avoid excessive requests.
