#!/bin/bash
# Check PASS_MAX_DAYS in /etc/login.defs (ignores comments).

value=$(awk '/^[[:space:]]*PASS_MAX_DAYS[[:space:]]+[0-9]+/ {v=$2} END {print v}' /etc/login.defs)

if [ -z "${value}" ]; then
    echo "No PASS_MAX_DAYS found in /etc/login.defs"
    exit 1
fi

if [ "${value}" -gt 365 ]; then
    echo "PASS_MAX_DAYS in /etc/login.defs is ${value}; required: 365 or less."
    exit 1
fi

echo "PASS_MAX_DAYS in /etc/login.defs is ${value}."
exit 0
