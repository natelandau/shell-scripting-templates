#! /dev/null/bash

function bash_path_update ()
{

    #
    ## General updater for paths
    #
    # Takes arguments of directories and variable name of path.
    # Dirs provided prior to the variable name get precedence.
    # Dirs provided after the variable name are pushed down.
    # Duplicate dirs will be removed.
    # And finally, not recommended when paths contain dirs on NFS,
    #   each entry is checked for existence and type before assignment.
    #
    # Ex:
    #   PATH='DirA:DirB:Dir1:Dir9:DirC:DirC:DirD'
    #   bash_path_update Dir1 Dir2 PATH Dir8 Dir9
    # Variable PATH will now be..
    #   PATH='Dir1:Dir2:DirA:DirB:DirC:DirD:Dir8:Dir9'
    #

    declare vars=(
        fnc fnc_return      # Function name and return value.
        args arg            # Argument[s] to function.
        name                # Name of path variable.
        old new             # Old and new values of path variable.
        add_head add_hind   # Values to add ahead or behind current values.
        I J K               # Iterators for loops.
    )
    declare ${vars[*]}

    fnc="${FUNCNAME}"
    fnc_return=0

    args=( "${@}" )
    add_head=()
    add_hind=()

    for arg in "${args[@]}"
    do
        # If path variable name isn't found yet ..
        if [ -z "${name}" ]
        then
            # .. then add argument to be added ahead of old values,
            [[ "${arg}" =~ [/:] ]] || {
                # unless this argument *is* the name of the path variable.
                name="${arg}"
                continue
            }
            add_head=( "${add_head[@]}" "${arg}" )
        else
            # Otherwise, add this argument to be added behind old values.
            add_hind=( "${add_hind[@]}" "${arg}" )
        fi
    done

    # No path variable found? Rudely exit!
    [ -n "${name}" ] || return 1

    # Should be exported already, but just in case.
    export "${name}"

    # Store old path variable value.
    printf -v old 'old="${%s}"' "${name}"
    eval "${old}"

    # Add new dirs ahead of old values,
    for arg in "${add_head[@]}"
    do
        # but first remove any duplicates from old values,
        while [[ ":${old}:" =~ ^:(.*:)?${arg}(:.*)?:$ ]]
        do
            old="${BASH_REMATCH[1]%:}:${BASH_REMATCH[2]#:}"
        done
        # and, of course, don't add it back if it isn't a directory.
        [ -d "${arg}/." ] || continue
        new="${new}${arg}:"
    done

    new="${new}${old}"

    # Add new dirs behind of new values,
    for arg in "${add_hind[@]}"
    do
        # but first remove any duplicates from new values,
        while [[ ":${new}:" =~ ^:(.*:)?${arg}(:.*)?:$ ]]
        do
            new="${BASH_REMATCH[1]%:}:${BASH_REMATCH[2]#:}"
        done
        # and, of course, don't add it back if it isn't a directory.
        [ -d "${arg}/." ] || continue
        new="${new}:${arg}"
    done

    # Assign new values to path variable.
    printf -v new '%s="%s"' "${name}" "${new}"
    eval "${new}"

    return "${fnc_return}"

}
