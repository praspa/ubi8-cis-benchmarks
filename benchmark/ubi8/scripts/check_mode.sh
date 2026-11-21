#!/bin/bash
# Usage: check_mode.sh <path> <max_mode>
# Passes when <path> grants no permission bits beyond <max_mode>,
# i.e. its mode is "<max_mode> or more restrictive" as CIS phrases it.

path="$1"
max="$2"

if [ -z "$path" ] || [ -z "$max" ]; then
    echo "usage: $0 <path> <max_mode>"
    exit 2
fi

mode=$(stat -c '%a' "$path") || exit 2

if (( (8#$mode & ~8#$max) != 0 )); then
    echo "$path has mode $mode; expected $max or more restrictive."
    exit 1
fi

echo "$path has mode $mode (max $max)."
exit 0
