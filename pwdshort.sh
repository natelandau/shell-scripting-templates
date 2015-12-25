#! /dev/null/bash

function pwdshort ()
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
        [[ ! "${curpath}" =~ ^${HOME}(/.*)?$ ]] \
            || newpath="${tc_tilde}${BASH_REMATCH[1]}"
        printf '%s\n' "${newpath}"
    done

}
