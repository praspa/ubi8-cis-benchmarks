#!/bin/bash

RC=0

test_lines=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,5)

if [ $? -ne 0 ]; then
    echo "No PASS_MAX_DAYS found assoicated with each user in /etc/shadow."
    RC=1
else

    for line in "${test_lines}"; do

        pass_max_days=$(echo "${line}" | grep -oE '[0-9]+')

        if [ ${pass_max_days} -gt 365 ]; then
            echo "Entry:<${line}>"
            echo "PASS_MAX_DAYS > 365 for User in /etc/shadow"
            RC=1
        fi

    done

fi


exit $RC