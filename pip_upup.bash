#! /dev/null/bash

function pip_upup ()
{

    declare IFS tmps tmp
    
    IFS=$'\n'
    tmps=( $( pip list -lo ) )
    IFS=$' \t\n'

    for tmp in "${tmps[@]}"
    do
        [[ "${tmp}" =~ \(Current:.*Latest: ]] || continue
        printf '\n#-- %s --#\n' "${tmp}"
        pip install --upgrade "${tmp%% *}" 2>&1 #|
            #egrep -v --line-buffered "^(Downloading/unpacking |Cleaning up\.\.\.|Storing complete log in |Requirement already up-to-date: )"
    done

    printf '\n#-- Current Status --#\n'
    pip list -lo
    
}
