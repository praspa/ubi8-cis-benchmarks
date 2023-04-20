#!/bin/bash

RC=0

test_lines=$(grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,6)

if [ $? -ne 0 ]; then
    echo "No PASS_WARN_AGE found assoicated with each user in /etc/shadow."
    RC=1
else

    for line in "${test_lines}"; do

        pass_warn_age=$(echo "${line}" | grep -oE '[0-9]+')

        if [ ${pass_warn_age} -lt 7 ]; then
            echo "Entry:<${line}>"
            echo "PASS_WARN_AGE < 7 for User in /etc/shadow"
            RC=1
        fi
    done

fi


exit $RC