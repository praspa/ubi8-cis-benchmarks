#!/bin/bash

FILE="$1"

RC=0

test_lines=$(grep -P '^\h*password\h+(requisite|sufficient)\h+(pam_pwhistory\.so|pam_unix\.so)\h+([^#\n\r]+\h+)?remember=([5-9]|[1-9][0-9]+)\h*(\h+.*)?$' "${FILE}")

if [ $? -ne 0 ]; then
    echo "No password history configuration found in ${FILE}"
    RC=1
else

    for line in "${test_lines}"; do

        remember_count=$(echo "${line}" | sed -e "s/remember=//" | grep -E '[0-9]+')

        if [ ${remember_count} -lt 5 ]; then
            echo "Password history remember: ${remember_count} is < 5 in ${FILE}."
            RC=1
        fi

    done

fi


exit $RC