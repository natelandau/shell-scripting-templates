#! /dev/null/bash

function ssh_hosts ()
{
    cut -d, -f1 < ~/.ssh/known_hosts | cut -d' ' -f1 | egrep "${@}"
}

function ssh_known_hosts_rm_ln ()
{
    declare line
    for line in "${@}"
    do
        printf "${FUNCNAME}: Removing line [ %s ]\n" "${line}"
        sed -i~ "${line}d" ~/.ssh/known_hosts
    done
}

function ssh_debug_test ()
{
    ssh -vvv -oControlPath=none "${@}" echo OKOKOK 2>&1 |
        egrep --line-buffered '(debug[0-9]: (Reading|.*: Applying|identity|Found|key:|load_hostkeys:|Offering)|Authenticat|OKOKOK)'
}
