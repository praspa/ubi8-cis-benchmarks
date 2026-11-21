#!/bin/bash
# CIS 5.4.2 Ensure lockout for failed password attempts is configured.
# Requires deny <= 5 and unlock_time >= 900 (or 0 = never auto-unlock) on every
# pam_faillock.so auth line. Values not on the line fall back to
# /etc/security/faillock.conf, then to pam_faillock defaults (deny=3, unlock_time=600).

FILE="$1"
FAILLOCK_CONF="/etc/security/faillock.conf"

RC=0

conf_value() {
    [ -r "${FAILLOCK_CONF}" ] && awk -F= -v k="$1" '$1 ~ "^[[:space:]]*"k"[[:space:]]*$" {gsub(/[[:space:]]/, "", $2); v=$2} END {print v}' "${FAILLOCK_CONF}"
}

test_lines=$(grep -E '^\s*auth\s+required\s+pam_faillock\.so\s+' "${FILE}")

if [ -z "${test_lines}" ]; then
    echo "No pam_faillock configuration found in ${FILE}"
    exit 1
fi

while read -r line; do
    deny_count=$(echo "${line}" | grep -oE '\bdeny=[0-9]+' | cut -d= -f2)
    unlock_time=$(echo "${line}" | grep -oE '\bunlock_time=[0-9]+' | cut -d= -f2)

    [ -z "${deny_count}" ] && deny_count=$(conf_value deny)
    [ -z "${unlock_time}" ] && unlock_time=$(conf_value unlock_time)
    deny_count=${deny_count:-3}
    unlock_time=${unlock_time:-600}

    echo "Line:<${line}> deny=${deny_count} unlock_time=${unlock_time}"

    if [ "${deny_count}" -gt 5 ] || [ "${deny_count}" -lt 1 ]; then
        echo "Deny count: ${deny_count} is not between 1 and 5 in ${FILE}."
        RC=1
    fi

    if [ "${unlock_time}" -ne 0 ] && [ "${unlock_time}" -lt 900 ]; then
        echo "Unlock Time: ${unlock_time} is < 900 in ${FILE}."
        RC=1
    fi
done <<< "${test_lines}"

exit $RC
