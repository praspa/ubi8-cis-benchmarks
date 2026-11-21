#!/bin/bash
# Check PASS_MIN_DAYS in /etc/login.defs (ignores comments).

value=$(awk '/^[[:space:]]*PASS_MIN_DAYS[[:space:]]+[0-9]+/ {v=$2} END {print v}' /etc/login.defs)

if [ -z "${value}" ]; then
    echo "No PASS_MIN_DAYS found in /etc/login.defs"
    exit 1
fi

if [ "${value}" -lt 7 ]; then
    echo "PASS_MIN_DAYS in /etc/login.defs is ${value}; required: 7 or more."
    exit 1
fi

echo "PASS_MIN_DAYS in /etc/login.defs is ${value}."
exit 0
