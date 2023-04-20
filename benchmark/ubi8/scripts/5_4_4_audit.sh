#!/bin/bash

FILE="$1"

RC=0

test_lines=$(grep -E '^\s*password\s+sufficient\s+pam_unix.so' "${FILE}")

if [ $? -ne 0 ]; then
    echo "No password hashing algorithm configuration found in ${FILE}"
    RC=1
else

    for line in "${test_lines}"; do

        echo "${line}" | grep 'sha512'

        if [ $? -ne 0 ]; then
            echo "Password Hashing algoritm in ${FILE} does not equal sha512"
            RC=1
        fi

    done

fi


exit $RC