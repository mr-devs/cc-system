# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal collection of Claude Code system-wide configuration: skills, statusline scripts, and other utilities.

## Repository structure

```
cc-system/
├── helper_scripts/
│   └── sync_claude_configs.sh # Copies settings.json and statusline.sh from ~/.claude/ into the repo
├── skills/                    # Project-local skills (copied to ~/.claude/skills/ for global use)
│   ├── create-skill/SKILL.md  # Skill for authoring new skills
│   └── nyhan-review/SKILL.md  # Manuscript/PAP screening assistant for political science
└── statusline/
    ├── statusline.sh          # Bash script for Claude Code's statusline
    └── README.md              # Setup instructions for the statusline
```

## Skills

Skills live in `skills/<skill-name>/SKILL.md`. Each `SKILL.md` requires YAML frontmatter:

```yaml
---
name: skill-name
description: Use when [triggering conditions — no workflow summary]
# Optional fields:
disable-model-invocation: true   # prevents auto-trigger; use for side-effect skills
argument-hint: "[description]"   # shown to user when invoking
context: fork                    # run in subagent with no conversation history
allowed-tools: [Read, Write]     # restrict tool access
---
```

Key rules for skill content:
- `description` must start with "Use when..." and describe only triggering conditions
- Name: lowercase letters, numbers, hyphens only (max 64 chars)
- Keep `SKILL.md` under 500 lines; move heavy reference material to separate files
- Optional supporting files: `reference.md`, `examples/`

To make a skill globally available, copy the skill directory to `~/.claude/skills/`.

## Statusline

`statusline/statusline.sh` is a macOS-only bash script that reads a JSON payload from Claude Code via stdin and outputs a formatted status display. It fetches usage data from the Anthropic OAuth API and caches results to `/tmp/claude_usage_cache.json`.

To deploy: copy `statusline/statusline.sh` to `~/.claude/statusline.sh`, make executable, and add to `~/.claude/settings.json`. Or run `helper_scripts/sync_claude_configs.sh` to pull the latest versions of both `statusline.sh` and `settings.json` from `~/.claude/` back into the repo.
```json
{ "statusline": { "command": "bash ~/.claude/statusline.sh" } }
```

Configurable constants at the top of the script: `CACHE_TTL` (seconds) and `LOW_BALANCE_THRESHOLD` (percent).
