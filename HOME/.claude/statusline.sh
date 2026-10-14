#!/usr/bin/env bash
# ~/.claude/statusline.sh — single-line status for Claude Code

set -euo pipefail

# Environment
USE_ASCII="${CLAUDE_STATUSLINE_ASCII:-0}"
USE_NERDFONT="${CLAUDE_STATUSLINE_NERDFONT:-0}"
USE_POWERLINE="${CLAUDE_STATUSLINE_POWERLINE:-$USE_NERDFONT}"
USE_TRUECOLOR=0
[[ "${COLORTERM:-}" == "truecolor" || "${COLORTERM:-}" == "24bit" ]] && USE_TRUECOLOR=1

# Colors
RST='\033[0m'
CYAN='\033[36m'
BLUE='\033[34m'
GRAY='\033[90m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
PURPLE='\033[35m'
# Refined colors (fallback 256-color values; degrade to same base when no truecolor)
GREEN_BRIGHT="$GREEN"
YELLOW_OLIVE="$YELLOW"
ORANGE="$YELLOW"
ORANGE_RED="$RED"
RED_BRIGHT="$RED"
if (( USE_TRUECOLOR )); then
  PURPLE='\033[38;2;114;102;234m'
  GREEN_BRIGHT='\033[38;2;46;204;113m'
  YELLOW_OLIVE='\033[38;2;186;186;64m'
  ORANGE='\033[38;2;241;161;15m'
  ORANGE_RED='\033[38;2;233;101;44m'
  RED_BRIGHT='\033[38;2;231;76;60m'
fi

# Symbols
if [[ "$USE_ASCII" == "1" ]]; then
  S_BRAND="<>"
  S_BRANCH=">"
  S_TIME="T"
  SEP=" | "
elif [[ "$USE_NERDFONT" == "1" ]]; then
  S_BRAND="◆"
  S_BRANCH=">"
  S_TIME="T"
  [[ "$USE_POWERLINE" == "1" ]] && SEP="  " || SEP=" │ "
else
  S_BRAND="◆"
  S_BRANCH="⎇  "
  S_TIME="⌛ "
  [[ "$USE_POWERLINE" == "1" ]] && SEP="  " || SEP=" │ "
fi

# Fallback
fallback_prompt() { printf '%b' "${GRAY}${1:-─}${RST}"; exit 0; }
command -v jq &>/dev/null || fallback_prompt "─ │ jq not found"

# Read JSON (only needed fields)
input=$(cat)
# echo "$input" > /tmp/statusline-debug.json
parsed=$(echo "$input" | jq -r '
  (.model.display_name // ""),
  (.context_window.used_percentage // 0 | tostring),
  (.workspace.current_dir // "." | split("/") | last),
  (.worktree.branch // ""),
  (.cost.total_duration_ms // 0 | tostring),
  (.context_window.context_window_size // 0 | tostring),
  (.worktree.name // ""),
  (.agent.name // ""),
  (.workspace.current_dir // "."),
  (.effort.level // ""),
  "END"
' 2>/dev/null) || fallback_prompt "─ │ parse error"

{
  read -r model_name
  read -r ctx_pct
  read -r dir
  read -r branch
  read -r duration_ms
  read -r ctx_size
  read -r wt_name
  read -r agent_name
  read -r cwd_full
  read -r effort_val
  read -r _sentinel
} <<< "$parsed"

model="${model_name:-─}"

# Context bar
pct_int=${ctx_pct%.*}; pct_int=${pct_int:-0}
(( pct_int < 0 )) && pct_int=0
(( pct_int > 100 )) && pct_int=100
bar_filled=$(( pct_int / 10 ))
(( bar_filled > 10 )) && bar_filled=10

GRAD_R=(46 116 186 241 239 236 233 231 211 192)
GRAD_G=(204 195 186 196 161 126 101 76 66 57)
GRAD_B=(113 89 64 15 24 34 44 60 50 43)

bar=""
if [[ "$USE_ASCII" == "1" ]]; then
  for (( i=0; i<10; i++ )); do
    [[ $i -lt $bar_filled ]] && bar+="#" || bar+="-"
  done
elif (( USE_TRUECOLOR )); then
  for (( i=0; i<10; i++ )); do
    if [[ $i -lt $bar_filled ]]; then
      bar+="\\033[38;2;${GRAD_R[$i]};${GRAD_G[$i]};${GRAD_B[$i]}m█"
    else
      bar+="\\033[38;2;60;60;60m░"
    fi
  done
  bar+="${RST}"
else
  if (( pct_int >= 90 )); then
    bar_color="$RED"
  elif (( pct_int >= 70 )); then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi
  for (( i=0; i<10; i++ )); do
    [[ $i -lt $bar_filled ]] && bar+="█" || bar+="░"
  done
  bar="${bar_color}${bar}${RST}"
fi

if (( pct_int >= 90 )); then
  pct_color="$RED"
elif (( pct_int >= 70 )); then
  pct_color="$YELLOW"
else
  pct_color="$GREEN"
fi
ctx_warn=""
(( pct_int >= 90 )) && ctx_warn="${RED}${S_WARN:- 🚨}${RST}"

ctx_label=""
if [[ "$model" != *context* && "$model" != *Context* ]]; then
  ctx_size_int=${ctx_size:-0}
  if (( ctx_size_int >= 1000000 )); then
    ctx_label="  ${GRAY}1M${RST}"
  elif (( ctx_size_int >= 200000 )); then
      ctx_label="  ${GRAY}200k${RST}"
  fi
fi

# Elapsed time
dur_section=""
dur_ms=${duration_ms:-0}
if (( dur_ms > 0 )); then
  dur_sec=$((dur_ms / 1000))
  dur_min=$((dur_sec / 60))
  dur_s=$((dur_sec % 60))
  (( dur_min > 0 || dur_s > 0 )) && dur_section="${SEP}${GRAY}${S_TIME}${dur_min}m${dur_s}s${RST}"
fi

# Git branch with cache (per-cwd to avoid cross-session collisions)
GIT_CACHE_MAX_AGE=5
git_branch="${branch:-}"
dirty=""
GIT_CACHE=""
if [[ -n "${cwd_full:-}" ]]; then
  cwd_hash=$(printf '%s' "$cwd_full" | sha1sum | cut -c1-12)
  GIT_CACHE="/tmp/claude-statusline-git-cache-${cwd_hash}"
fi
git_cache_is_stale() {
  [[ ! -f "$GIT_CACHE" ]] && return 0
  local cache_age=$(( $(date +%s) - $(stat -c %Y "$GIT_CACHE" 2>/dev/null || echo 0) ))
  (( cache_age > GIT_CACHE_MAX_AGE ))
}
if [[ -n "$GIT_CACHE" && -d "${cwd_full:-}" ]]; then
  if git_cache_is_stale; then
    if git -C "$cwd_full" rev-parse --git-dir &>/dev/null; then
      cached_branch="${git_branch}"
      [[ -z "$cached_branch" ]] && cached_branch=$(git -C "$cwd_full" -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null) || true
      [[ -z "$cached_branch" ]] && cached_branch=$(git -C "$cwd_full" rev-parse --short HEAD 2>/dev/null) || true
      cached_dirty=""
      if ! git -C "$cwd_full" -c core.useBuiltinFSMonitor=false diff --quiet 2>/dev/null \
         || ! git -C "$cwd_full" -c core.useBuiltinFSMonitor=false diff --cached --quiet 2>/dev/null; then
        cached_dirty="*"
      fi
      echo "${cached_branch}|${cached_dirty}" > "$GIT_CACHE"
    else
      echo "|" > "$GIT_CACHE"
    fi
  fi
  if [[ -f "$GIT_CACHE" ]]; then
    IFS='|' read -r cached_br cached_dt < "$GIT_CACHE"
    [[ -z "$git_branch" ]] && git_branch="${cached_br}"
    dirty="${cached_dt}"
  fi
fi

# Build the single line
line="${PURPLE}${S_BRAND}${RST} ${CYAN}${model}${RST}"
line+="${SEP}${bar} ${pct_color}${pct_int}%${RST}${ctx_warn}${ctx_label}"
line+="${dur_section}"

# Append branch if present
if [[ -n "$git_branch" ]]; then
  line+="${SEP}${GRAY}${S_BRANCH}${git_branch}${dirty}${RST}"
fi

# Append directory
line+="${SEP}${BLUE}${dir}${RST}"

# Append agent/worktree if any
if [[ -n "${wt_name:-}" ]]; then
  line+="${SEP}${YELLOW}⚙  worktree:${wt_name}${RST}"
elif [[ -n "${agent_name:-}" ]]; then
  line+="${SEP}${YELLOW}⚙  ${agent_name}${RST}"
fi

# Append effort level
if [[ -n "${effort_val:-}" ]]; then
  case "${effort_val,,}" in
    low)    _e_color="$GREEN_BRIGHT" ;;
    medium) _e_color="$YELLOW_OLIVE" ;;
    high)   _e_color="$ORANGE" ;;
    xhigh)  _e_color="$ORANGE_RED" ;;
    max)    _e_color="$RED_BRIGHT" ;;
    *)      _e_color="$GRAY" ;;
  esac
  line+="${SEP}✨ ${_e_color}${effort_val} · effort${RST}"
fi

printf '%b\n' "$line"

