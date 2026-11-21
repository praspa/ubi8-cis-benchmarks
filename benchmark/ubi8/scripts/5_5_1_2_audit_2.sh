#!/bin/bash
# Check PASS_MIN_DAYS (field 4 of /etc/shadow) for every user that has a password set.
# An empty field means the value is not set, which also fails.

awk -F: '($2 !~ /^[!*]/ && $2 != "") { if ($4 == "" || $4 < 7) { print "User: " $1 " has PASS_MIN_DAYS: <" $4 ">; required: 7 or more."; bad=1 } } END { exit bad }' /etc/shadow
