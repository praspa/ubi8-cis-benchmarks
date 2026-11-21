#!/bin/bash
# CIS 5.4.3 Ensure password reuse is limited (remember >= 5).

FILE="$1"

RC=0

test_lines=$(grep -P '^\h*password\h+(requisite|required|sufficient)\h+(pam_pwhistory\.so|pam_unix\.so)\h+([^#\n\r]+\h+)?remember=\d+\b' "${FILE}")

if [ -z "${test_lines}" ]; then
    echo "No password history configuration found in ${FILE}"
    exit 1
fi

while read -r line; do
    remember_count=$(echo "${line}" | grep -oE '\bremember=[0-9]+' | cut -d= -f2)

    if [ "${remember_count}" -lt 5 ]; then
        echo "Password history remember: ${remember_count} is < 5 in ${FILE}."
        RC=1
    else
        echo "Password history remember: ${remember_count} in ${FILE}."
    fi
done <<< "${test_lines}"

exit $RC
