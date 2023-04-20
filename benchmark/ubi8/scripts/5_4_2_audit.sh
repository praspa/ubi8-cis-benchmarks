#!/bin/bash

FILE="$1"

RC=0

test_lines=$(grep -E '^\s*auth\s+required\s+pam_faillock.so\s+' "${FILE}")

if [ $? -ne 0 ]; then
    echo "No pam_faillock configuration found in ${FILE}"
    RC=1
else

    for line in "${test_lines}"; do

        deny_count=$(echo "${line}" | sed -e "s/deny=//" | grep -E '[0-9]+')

        if [ ${deny_count} -gt 5]; then
            echo "Deny count: ${deny_count} is > 5 in ${FILE}."
            RC=1
        fi

        unlock_time=$(echo "${line}" | sed -e "s/unlock_time=//" | grep -E '[0-9]+')

        if [ ${unlock_time} -lt 900]; then
            echo "Unlock Time: ${unlock_time} is < 900 in ${FILE}."
            RC=1
        fi

    done

fi


exit $RC