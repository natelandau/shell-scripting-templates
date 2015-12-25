#! /dev/null/bash

function function1lfh ()
{

    #
    ## Generate 1LFH ( 1-Liner-From-Hell ) function from extant function.
    #
    # Will not work for complex functions containing here-files, etc.
    #

    declare fnc_names fnc_name fnc_src rgxs rgx tc_nln

    fnc_names="${@}"

    printf -v tc_nln '\n'

    # For each function name provided ..
    for fnc_name in "${fnc_names[@]}"
    do

        # Prefix with 'function' declaration, just cuz that's how I roll.
        printf -v fnc_src 'function %s' "$( declare -f "${fnc_name}" )"

        # Remove spaces from line-endings.
        rgx="(.*[^ ])([ ]+)(${tc_nln}.*)"
        while [[ "${fnc_src}" =~ ${rgx} ]]
        do
            fnc_src="${BASH_REMATCH[1]}${BASH_REMATCH[3]}"
        done

        # Remove whitespace before command-group ending ..
        rgx='(.*)('"${tc_nln}"'[[:blank:]]*)(}.*)'
        while [[ "${fnc_src}" =~ ${rgx} ]]
        do
            # .. and replace with '; '
            fnc_src="${BASH_REMATCH[1]}; ${BASH_REMATCH[3]}"
        done

        # Remove vertical and horizontal space before each line ..
        rgx="(.*)(${tc_nln}[[:blank:]]*)(.*)"
        while [[ "${fnc_src}" =~ ${rgx} ]]
        do
            # .. and replace with a single space.
            fnc_src="${BASH_REMATCH[1]} ${BASH_REMATCH[3]}"
        done

        # Display the new 1LFH
        printf '\n%s\n' "${fnc_src}"

    done

}
