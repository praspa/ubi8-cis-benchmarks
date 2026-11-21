#!/bin/bash
# Check PASS_MAX_DAYS (field 5 of /etc/shadow) for every user that has a password set.
# An empty field means the value is not set, which also fails.

awk -F: '($2 !~ /^[!*]/ && $2 != "") { if ($5 == "" || $5 > 365 || $5 < 0) { print "User: " $1 " has PASS_MAX_DAYS: <" $5 ">; required: 365 or less."; bad=1 } } END { exit bad }' /etc/shadow
