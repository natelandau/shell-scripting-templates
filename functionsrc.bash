#! /dev/null/bash

function functionsrc ()
{

    declare fnc_names fnc_name fnc_src rgx tc_nln

    fnc_names="${@}"

    printf -v tc_nln '\n'

    for fnc_name in "${fnc_names[@]}"
    do

        printf -v fnc_src 'function %s' "$( declare -f "${fnc_name}" )"

        rgx="(.*[^ ])(;[ ]*|[ ]+)(${tc_nln}.*)"
        while [[ "${fnc_src}" =~ ${rgx} ]]
        do
            fnc_src="${BASH_REMATCH[1]}${BASH_REMATCH[3]}"
        done

        printf '\n%s\n' "${fnc_src}"

    done

}
