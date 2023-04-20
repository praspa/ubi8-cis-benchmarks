#!/bin/bash

RC=0

pass_max_days=$(grep PASS_MIN_DAYS /etc/login.defs | grep -oE '[0-9]+')

if [ $? -ne 0 ]; then
    echo "No PASS_MIN_DAYS found in /etc/login.defs"
    RC=1
    exit $RC
fi

if [ ${pass_max_days} -lt 7 ]; then
    echo "PASS_MIN_DAYS configuration in /etc/login.defs is less than 7."
    RC=1
fi


exit $RC