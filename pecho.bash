#! /dev/null/bash

function pecho ()
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
            || newpath="${curpath/#${HOME}/${tc_tilde}}"
        printf '%s\n' "${newpath}"
    done

}
