#!/bin/bash 

RC=0

cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
    echo "Duplicate GID ($x) in /etc/group"
    RC=1
done


exit $RC
