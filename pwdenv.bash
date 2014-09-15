#! /dev/null/bash

function pwdenv ()
{

    declare vars=(
        paths
        curpath
        newpath
        tc_tilde
    )
    declare ${vars[*]}

    printf -v tc_tilde '~'

    paths=( "${@:-${PWD}}" )

    for curpath in "${paths[@]}"
    do
        [[ ! "${curpath}" =~ ^(${HOME}|${tc_tilde})(/.*)?$ ]] \
            || newpath="\${HOME}${BASH_REMATCH[2]}"
        printf '%s\n' "${newpath}"
    done

}
