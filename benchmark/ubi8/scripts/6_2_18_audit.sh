#!/bin/bash

RC=0

cut -d: -f1 /etc/group | sort | uniq -d | while read -r x; do
    echo "Duplicate group name ${x} in /etc/group"
    RC=1
done

exit $RC