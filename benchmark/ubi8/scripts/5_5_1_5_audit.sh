#!/bin/bash
# CIS 5.5.1.5 Ensure all users last password change date is in the past.
# Field 3 of /etc/shadow is days since the epoch; compare numerically with today.

today=$(( $(date +%s) / 86400 ))

awk -F: -v today="${today}" '($3 != "" && $3 > today) { print "User: " $1 " last password change (day " $3 ") is in the future."; bad=1 } END { exit bad }' /etc/shadow
