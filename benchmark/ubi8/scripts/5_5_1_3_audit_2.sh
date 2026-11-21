#!/bin/bash
# Check PASS_WARN_AGE (field 6 of /etc/shadow) for every user that has a password set.
# An empty field means the value is not set, which also fails.

awk -F: '($2 !~ /^[!*]/ && $2 != "") { if ($6 == "" || $6 < 7) { print "User: " $1 " has PASS_WARN_AGE: <" $6 ">; required: 7 or more."; bad=1 } } END { exit bad }' /etc/shadow
