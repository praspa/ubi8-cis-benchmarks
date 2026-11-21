#!/bin/bash

RC=1

passing=""

grep -Eiq '^\s*UMASK\s+(0[0-7][2-7]7|[0-7][2-7]7)\b' /etc/login.defs && grep -Eqi '^\s*USERGROUPS_ENAB\s*"?no"?\b' /etc/login.defs && grep -Eqs '^\s*session\s+(optional|requisite|required)\s+pam_umask\.so\b' /etc/pam.d/system-auth /etc/pam.d/password-auth /etc/pam.d/postlogin && passing=true

grep -REiq '^\s*UMASK\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\b' /etc/profile* /etc/bashrc* && passing=true

[ "$passing" = true ] && echo "Default user umask is set" && RC=0

exit $RC