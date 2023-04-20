#!/bin/bash

RC=0

for usr in $(cut -d: -f1 /etc/shadow); do 
    [[ $(chage --list $usr | grep '^Last password change' | cut -d: -f2) > $(date) ]] && echo "$usr :$(chage --list $usr | grep '^Last password change' | cut -d: -f2)" && RC=1; 
done

exit $RC