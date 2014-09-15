#! /bin/bash

# Add SSH keys en masse.
function ssh-adhd ()
{

    [ -n "${SSH_ID_RSA_LOAD}" ] || {
        printf "${FUNCNAME}: %s\n" "Load source not set ( SSH_ID_RSA_LOAD )"
        return 1
    }

    [ -r "${SSH_ID_RSA_LOAD}" ] || {
        printf "${FUNCNAME}: %s\n" "Load source not found ( ${SSH_ID_RSA_LOAD} )"
        return 2
    }

    declare K=

    {
        ssh-add -D
        for K in $(<"${SSH_ID_RSA_LOAD}")
        do
            [[ ! "${K}" =~ \.(pub|noload|disabled|off)$ ]] || continue
            [[ "${K}" == /* ]] || K=~/.ssh/"${K}"
            ssh-add "${K}"
        done
    } 2>&1 |
        sed \
            -e "/^All identities removed\.\$/d" \
            -e "/^[Ii]dentity added: /d" \
            -e "s=^=${FUNCNAME[0]}: =" \
            -e :END 1>&2

}
