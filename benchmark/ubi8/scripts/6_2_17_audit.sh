#!/bin/bash

RC=0

cut -d: -f1 /etc/passwd | sort | uniq -d | while read x; do
    echo "Duplicate login name ${x} in /etc/passwd"
    RC=1
done

exit $RC
