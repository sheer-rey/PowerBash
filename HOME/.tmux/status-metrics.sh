#!/bin/sh
# status-metrics.sh - tier-conditional system metrics for the tmux status line.
#
# Usage: status-metrics.sh <tier|width> [tmux-server-pid]
#   tier: w (wide), m (mid), n (narrow). The status-right format in .tmux.conf
#   buckets the client width into w/m/n inside the command string, so every
#   client of the same tier on a server shares ONE tmux-deduplicated execution
#   per refresh and no two samplers ever interleave on the state files.
#   A plain width number also works for manual runs (>=120 -> w, >=80 -> m).
#   The optional pid argument (tmux server pid from the format) keys the CPU
#   state per server, so several tmux servers under one account — or several
#   users sharing this machine — never split each other's sampling window.
#
#   Segments: CPU (6-block bar + percent), MEM (used percent of MemTotal minus
#   MemAvailable), DISK (usage percent of root filesystem), LOAD (1-minute average),
#   UP (uptime days/hours), date. I/O wait, docker and users are intentionally omitted.
#
# Layout per tier (segments are labelled with the icon knobs below; narrowing
# drops bars and auxiliary values, never the icons; an empty icon prints
# nothing, space included):
#   w : icon + bar + percent per metric, load, uptime, full date
#   m : icon + percent per metric, load, full date
#   n : compact icon + percent, time only
#
# Refresh design (paired with status-interval 1): CPU and MEM are sampled on
# every refresh so they react instantly; DISK and the date string are cached in
# a private per-user cache directory for slow_ttl seconds because they only move
# by the minute; the up string and LOAD come from plain builtin reads (zero
# forks). The CPU value is a delta since the previous refresh, primed on first run.
#
# Cache location: $XDG_RUNTIME_DIR (0700 per user under systemd) when available,
# else a per-user subdirectory of $TMPDIR//tmp — on shared machines this avoids
# predictable /tmp filenames that another user could pre-create and block.
#
# Colour: values and bars are tinted green/amber/red by severity using tmux
# #[fg=colourN] style codes, which the status line interprets in #() output.
#
# Cost note: reads /proc directly; replaces the old status-right which forked
# top twice plus free on every status refresh (~7-10 percent of a core on WSL2).

width_arg=${1:-100}
slow_ttl=20

# severity colour knobs: xterm 256-colour indices (0-255) tinting the bars and
# values below; 40/208/160 are a bright green/orange/red trio that stays
# readable on the light status background — change freely to taste
colour_ok=40      # healthy: <70%, LOAD < 0.7x cores
colour_warn=208   # busy:    70-89%, LOAD 0.7-1x cores
colour_crit=160   # high:    >=90%, LOAD >= 1x cores

# segment colour knobs for the non-metric segments, same 0-255 index space
colour_up=141      # UP (uptime) value
colour_date=81     # date / time string

# segment icon knobs: colour emoji rendered by the terminal's colour-emoji
# font; an empty icon hides that segment's icon AND its trailing space (clear
# a single knob to drop just that icon, or all six for a labels-free bar).
# Pick ONLY emoji whose base character is East Asian Width "W" (e.g. python3:
# unicodedata.east_asian_width(ch) == 'W'): text-style glyphs with a U+FE0F
# qualifier (gear U+2699, stopwatch U+23F1, ...) are Neutral width, tmux
# measures them as ONE column while the terminal paints TWO, which shows up as
# black-backed, misaligned icons in the status line. Nerd Font PUA glyphs are
# also single-width and safe there, but they draw much smaller than the block
# and emoji symbols around them, which is why emoji is the chosen style
icon_cpu=💻   # CPU    (laptop)
icon_mem=🧊   # MEM    (ice cube: cold RAM)
icon_disk=💽  # DISK   (minidisc)
icon_load=🔥  # LOAD   (fire: under pressure)
icon_up=🚀    # uptime (rocket: running since launch)
icon_date=📅  # date / time (calendar)

# demo mode switch: 1 pins CPU/MEM/DISK to low/mid/high sample values so all
# three severity colours render at once while tuning; 0 (default) shows live data
demo=0

# tier: letter passed by the status-right format, or derived from a numeric width
case $width_arg in
    [wmn]) tier=$width_arg ;;
    *[!0-9]*|'') tier=w ;;
    *) if [ "$width_arg" -ge 120 ]; then tier=w
       elif [ "$width_arg" -ge 80 ]; then tier=m
       else tier=n; fi ;;
esac

srv=${2:-manual}
uid=$(id -u)

# private cache directory (see header)
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -w "${XDG_RUNTIME_DIR:-}" ]; then
    cache_dir=$XDG_RUNTIME_DIR
else
    cache_dir="${TMPDIR:-/tmp}/tmux-metrics.$uid"
    [ -d "$cache_dir" ] || mkdir -p "$cache_dir" 2>/dev/null
fi
state="$cache_dir/tmux_cpu_state.$uid.$srv.$tier"
slow="$cache_dir/tmux_slow_cache.$uid"

# per-segment labels: icon plus one space when an icon is set; an empty icon
# knob prints nothing, no dangling space
cpu_lbl=$icon_cpu${icon_cpu:+' '}
mem_lbl=$icon_mem${icon_mem:+' '}
disk_lbl=$icon_disk${icon_disk:+' '}
load_lbl=$icon_load${icon_load:+' '}
up_lbl=$icon_up${icon_up:+' '}
date_lbl=$icon_date${icon_date:+' '}

# cpu: busy/total jiffies delta between two status refreshes; the state file is
# read and written with builtin only (no cat) to keep the per-second cost minimal
cur=$(awk '/^cpu /{t=0; for(i=2;i<=9;i++) t+=$i; print t, $5}' /proc/stat)
[ -f "$state" ] || printf '%s\n' "$cur" > "$state"
read -r pt pi < "$state"
set -- $cur
cpu=$(awk -v p="$pt" -v i="$pi" -v t="$1" -v idle="$2" 'BEGIN{
    dt = t - p; di = idle - i
    printf "%d", (dt > 0 ? (100 * (dt - di) + dt / 2) / dt : 0) }')
printf '%s\n' "$cur" > "$state"

# mem: used percent = (MemTotal - MemAvailable) / MemTotal, sampled every refresh
mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{
    printf "%d", (t > 0 ? (100 * (t - a) + t / 2) / t : 0) }' /proc/meminfo)

# monotonic clock from /proc/uptime seconds field (builtin read, no fork)
read -r uptick _ < /proc/uptime
uptick=${uptick%%.*}

# slow values (disk usage, full date): recompute at most every slow_ttl seconds;
# the date is the last cache field so its spaces survive the builtin read
c_ts='' c_disk='' c_now=''
if [ -f "$slow" ]; then read -r c_ts c_disk c_now < "$slow"; fi
case $c_ts in ''|*[!0-9]*) c_ts='' ;; esac
case $uptick in ''|*[!0-9]*) c_ts='' ;; esac
if [ -z "$c_ts" ] || [ "$uptick" -lt "$c_ts" ] \
        || [ $((uptick - c_ts)) -ge "$slow_ttl" ]; then
    disk=$(df -kP / | awk 'NR == 2 { gsub("%", "", $5); printf "%d", $5 }')
    now=$(date +'%a %m/%d/%Y %R %Z')
    printf '%s %s %s\n' "$uptick" "$disk" "$now" > "$slow.$$" \
        && mv -f "$slow.$$" "$slow"
    # sweep CPU state files left behind by previous tmux server restarts;
    # piggybacked here (runs at most every slow_ttl seconds, one cheap find)
    find "$cache_dir" -maxdepth 1 -name "tmux_cpu_state.$uid.*" -mmin +5 -delete 2>/dev/null
else
    disk=$c_disk now=$c_now
fi

# up: days+hours, or hours+minutes when under a day (builtin math from uptick)
d=$((uptick / 86400)); h=$((uptick % 86400 / 3600)); m=$((uptick % 3600 / 60))
if [ "$d" -gt 0 ]; then up="${d}d ${h}h"
elif [ "$h" -gt 0 ]; then up="${h}h ${m}m"
else up="${m}m"; fi

# load: 1-minute average, rendered as-is (already two decimals, builtin read)
read -r load1 _ < /proc/loadavg

# cores: online CPU count from sysfs (builtin read, no fork)
read -r online < /sys/devices/system/cpu/online
case $online in
    [0-9]*-[0-9]*) cores=$(( ${online##*-} + 1 )) ;;
    *) cores=1 ;;
esac

# demo mode: fixed 42/78/95 samples -> bars 3/6, 5/6, 6/6 filled, grading to
# ok/warn/crit colours; controlled by the demo knob at the top of this script
if [ "$demo" = 1 ]; then cpu=42 mem=78 disk=95; fi

# threshold grading: pick one of the three colour knobs per value; LOAD is
# graded against the core count; one awk grades all four values
set -- $(awk -v c="$cpu" -v m="$mem" -v d="$disk" -v l="$load1" -v n="$cores" \
    -v ok="$colour_ok" -v warn="$colour_warn" -v crit="$colour_crit" 'BEGIN{
    print (c < 70 ? ok : (c < 90 ? warn : crit)), (m < 70 ? ok : (m < 90 ? warn : crit)),
          (d < 70 ? ok : (d < 90 ? warn : crit)), (l < 0.7 * n ? ok : (l < n ? warn : crit)) }')

# bar: 6 block segments rounded from a percent value
bar() {
    awk -v p="$1" 'BEGIN{
        n = int((p * 6 + 50) / 100)
        for (i = 0; i < n; i++) printf "▓"
        for (i = n; i < 6; i++) printf "░" }'
}

if [ "$tier" = w ]; then
    body="$cpu_lbl#[fg=colour$1]$(bar "$cpu") $(printf '%d%%' "$cpu")#[default] | $mem_lbl#[fg=colour$2]$(bar "$mem") $(printf '%d%%' "$mem")#[default] | $disk_lbl#[fg=colour$3]$(bar "$disk") $(printf '%d%%' "$disk")#[default] | $load_lbl#[fg=colour$4]$load1#[default] | $up_lbl#[fg=colour$colour_up]$up#[default] | $date_lbl#[fg=colour$colour_date]$now#[default]"
elif [ "$tier" = m ]; then
    body="$cpu_lbl#[fg=colour$1]$(printf '%d%%' "$cpu")#[default] | $mem_lbl#[fg=colour$2]$(printf '%d%%' "$mem")#[default] | $disk_lbl#[fg=colour$3]$(printf '%d%%' "$disk")#[default] | $load_lbl#[fg=colour$4]$load1#[default] | $date_lbl#[fg=colour$colour_date]$now#[default]"
else
    hm=${now#* }; hm=${hm#* }; hm=${hm%% *}   # HH:MM: third field of the cached date
    body="$icon_cpu#[fg=colour$1]$(printf '%d%%' "$cpu")#[default] | $icon_mem#[fg=colour$2]$(printf '%d%%' "$mem")#[default] | $icon_disk#[fg=colour$3]$(printf '%d%%' "$disk")#[default] | $date_lbl#[fg=colour$colour_date]$hm#[default]"
fi

printf '%s' "$body"
