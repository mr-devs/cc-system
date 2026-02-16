#!/bin/bash

# --- CONFIGURATION ---
CACHE_FILE="/tmp/claude_usage_cache.json"
CACHE_TTL=300 # 5 minutes
LOW_BALANCE_THRESHOLD=90 # % at which weekly bar turns Bold Red
# ---------------------

# 1. READ CLAUDE CODE INPUT
INPUT=$(cat)
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Claude"')
CWD=$(pwd | sed "s|$HOME|~|")
CTX_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# 2. CACHED API FETCH (Mac Keychain & Curl)
fetch_usage() {
    TOKEN_JSON=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    ACCESS_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.claudeAiOauth.accessToken // empty')

    if [ -n "$ACCESS_TOKEN" ]; then
        curl -s "https://api.anthropic.com/api/oauth/usage" \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-code/2.0.32" > "$CACHE_FILE"
    fi
}

# Check cache freshness
if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE"))) -gt $CACHE_TTL ]; then
    if [ ! -f "$CACHE_FILE" ]; then fetch_usage; else fetch_usage & fi
fi

# 3. DATA PARSING & TIMERS
SES_PCT=$(jq -r '.five_hour.utilization // 0' "$CACHE_FILE" 2>/dev/null | cut -d. -f1)
WK_PCT=$(jq -r '.seven_day.utilization // 0' "$CACHE_FILE" 2>/dev/null | cut -d. -f1)

# --- Session Timer (Countdown Style) ---
SES_RESET_ISO=$(jq -r '.five_hour.resets_at // empty' "$CACHE_FILE" 2>/dev/null)
SES_TIMER=""
if [ -n "$SES_RESET_ISO" ] && [ "$SES_RESET_ISO" != "null" ]; then
    CLEAN_SES=$(echo "$SES_RESET_ISO" | cut -d. -f1 | sed 's/Z//')
    # Step 1: Get Epoch in UTC
    SES_EPOCH=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$CLEAN_SES" "+%s" 2>/dev/null)
    NOW=$(date +%s)
    DIFF=$((SES_EPOCH - NOW))
    if [ $DIFF -gt 0 ]; then
        H=$((DIFF / 3600)); M=$(((DIFF % 3600) / 60))
        [ $H -gt 0 ] && SES_TIMER=" (resets in ${H}h ${M}m)" || SES_TIMER=" (resets in ${M}m)"
    else
        SES_TIMER=" (refreshing...)"
    fi
fi

# --- Weekly Timer (Calendar Style - Two-Step Local Fix) ---
WK_RESET_ISO=$(jq -r '.seven_day.resets_at // empty' "$CACHE_FILE" 2>/dev/null)
WK_TIMER=""
if [ -n "$WK_RESET_ISO" ] && [ "$WK_RESET_ISO" != "null" ]; then
    CLEAN_WK=$(echo "$WK_RESET_ISO" | cut -d. -f1 | sed 's/Z//')
    
    # 1. Parse string as UTC to get a universal Unix Timestamp
    WK_EPOCH=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$CLEAN_WK" "+%s" 2>/dev/null)
    
    # 2. Render that timestamp into Local Time (Thu 2:59 PM)
    WK_TIMER=$(date -r "$WK_EPOCH" +" (Resets %a %l:%M %p)" 2>/dev/null)
fi

# 4. UI HELPERS
ESC=$'\033'; RST="${ESC}[0m"; DIM="${ESC}[90m"; BOLD_RED="${ESC}[1;31m"

get_color() {
    local pct=$1 is_weekly=$2
    if [ "$is_weekly" == "true" ] && [ "$pct" -ge "$LOW_BALANCE_THRESHOLD" ]; then echo "$BOLD_RED"
    elif [ "$pct" -ge 80 ]; then echo "${ESC}[31m"; elif [ "$pct" -ge 50 ]; then echo "${ESC}[33m"
    else echo "${ESC}[32m"; fi
}

draw_line() {
    local label=$1 pct=$2 extra=$3 is_weekly=$4
    local color=$(get_color "$pct" "$is_weekly")
    local width=15
    local filled=$(( pct * width / 100 ))
    [ "$filled" -gt "$width" ] && filled=$width
    
    local bar="${color}"
    for ((i=0; i<filled; i++)); do bar+="█"; done
    bar+="${DIM}"
    for ((i=0; i<(width-filled); i++)); do bar+="░"; done
    bar+="${RST}"
    
    printf "%-15s %3d%% | %b%s\n" "$label" "$pct" "$bar" "$extra"
}

# 5. FINAL OUTPUT
echo "[$MODEL] | $CWD"
draw_line "Context" "$CTX_PCT" "" "false"
draw_line "Session Limit" "${SES_PCT:-0}" "$SES_TIMER" "false"
draw_line "Weekly Limit" "${WK_PCT:-0}" "$WK_TIMER" "true"
