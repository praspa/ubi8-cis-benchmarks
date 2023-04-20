#!/bin/bash

RC=0


test1=$(grep -P -- "^\h*-w\h+$(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//' | tr -d \")\h+-p\h+wa\h+-k\h+\H+\h*(\h+.*)?$" /etc/audit/rules.d/*.rules)

test2=$(auditctl -l | grep -P -- "^\h*-w\h+$(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//' | tr -d \")\h+-p\h+wa\h+-k\h+\H+\h*(\h+.*)?$")

test3=$(echo "-w $(grep -r logfile /etc/sudoers* | sed -e 's/.*logfile=//;s/,? .*//' | tr -d \") -p wa -k actions")

echo "Sudolog audit def check /etc/audit/rules.d/*rules:<${test1}"

echo "Sudolog audit def check auditctl:<${test2}"

echo "Sudolog audit def check /etc/sudoers*:<${test3}"

if [[ -z $test1 || -z $test2 || -z $test3 ]]; then
  echo 'One or more sudolog checks are undefined.'
  exit 1
fi

if [ "${test1}" != "${test2}" ]; then
    echo "Sudolog audit rules do not match between /etc/audit/rules.d/*.rules and auditctl."
    RC=1
fi

if [ "${test2}" != "${test3}" ]; then
    echo "Sudolog audit rules do not match between auditctl and /etc/sudoers*."
    RC=1
fi

if [ "${test3}" != "${test1}" ]; then
    echo "Sudolog audit rules do not match between /etc/sudoers* and /etc/audit/rules/*.rules."
    RC=1
fi

# todo: need check for valid file path here


exit $RC