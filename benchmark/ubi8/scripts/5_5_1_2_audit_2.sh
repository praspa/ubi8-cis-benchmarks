#!/bin/bash

RC=0

test_lines=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,4)

if [ $? -ne 0 ]; then
    echo "No PASS_MIN_DAYS found assoicated with each user in /etc/shadow."
    RC=1
else

    for line in "${test_lines}"; do

        pass_min_days=$(echo "${line}" | grep -oE '[0-9]+')

        if [ ${pass_min_days} -lt 7 ]; then
            echo "Entry:<${line}>"
            echo "PASS_MIN_DAYS < 7 for User in /etc/shadow"
            RC=1
        fi
    done

fi


exit $RC