#!/bin/bash

RC=0

test_lines=$(grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,7)

if [ $? -ne 0 ]; then
    echo "No INACTIVE days found assoicated with each user in /etc/shadow."
    RC=1
else

    for line in "${test_lines}"; do

        inactive_days=$(echo "${line}" | grep -oE '[0-9]+')

        if [ ${inactive_days} -gt 30 ]; then
            echo "Entry:<${line}>"
            echo "INACTIVE days > 30 for User in /etc/shadow"
            RC=1
        fi
    done

fi


exit $RC