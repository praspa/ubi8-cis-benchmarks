#!/bin/bash 

RC=0

awk -F: '($1!~/(root|halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1 " " $6 }' /etc/passwd | while read -r user dir; do
    if [ -d "$dir" ]; then
        
        file="$dir/.rhosts"
        
        if [ ! -h "$file" ] && [ -f "$file" ]; then 
            echo "User: \"$user\" file: \"$file\" exists"
            RC=1
        fi
    fi
done

exit $RC