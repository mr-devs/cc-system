#!/usr/bin/env bash
# Copies ~/.claude/settings.json and ~/.claude/statusline.sh to the root of this repository.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

copy_file() {
    local source="$1"
    local dest="$2"

    if [[ ! -f "$source" ]]; then
        echo "Error: $source not found." >&2
        exit 1
    fi

    if ! cp "$source" "$dest"; then
        echo "Error: Failed to copy $source to $dest." >&2
        exit 1
    fi

    echo "Copied $source to $dest"
}

copy_file "$HOME/.claude/settings.json"   "$REPO_ROOT/settings.json"
copy_file "$HOME/.claude/statusline.sh"   "$REPO_ROOT/statusline/statusline.sh"
