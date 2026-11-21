#!/bin/bash
# Check INACTIVE (field 7 of /etc/shadow) for every user that has a password set.
# An empty field means the value is not set, which also fails.

awk -F: '($2 !~ /^[!*]/ && $2 != "") { if ($7 == "" || $7 > 30 || $7 < 0) { print "User: " $1 " has INACTIVE: <" $7 ">; required: 30 or less."; bad=1 } } END { exit bad }' /etc/shadow
