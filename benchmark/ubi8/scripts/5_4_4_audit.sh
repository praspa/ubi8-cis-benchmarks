#!/bin/bash
# CIS 5.4.4 Ensure password hashing algorithm is SHA-512.

FILE="$1"

RC=0

test_lines=$(grep -E '^\s*password\s+sufficient\s+pam_unix\.so' "${FILE}")

if [ -z "${test_lines}" ]; then
    echo "No password hashing algorithm configuration found in ${FILE}"
    exit 1
fi

while read -r line; do
    if ! echo "${line}" | grep -qw 'sha512'; then
        echo "Password hashing algorithm is not sha512 in ${FILE}: <${line}>"
        RC=1
    fi
done <<< "${test_lines}"

exit $RC
