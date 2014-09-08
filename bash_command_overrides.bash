#! /dev/null/bash

function bash_command_overrides ()
{

    #
    ## Display list of commands defined multiple times.
    #
    # Includes BASH Alias/Keyword/Function/Builtin entries.
    #

    # List of local strings.
    declare vars_sl_=(

        fnc                     # Function name.
        tmp                     # General temporary variable.

        # TERM chars for regex/delim use.
        tc_spc tc_tab tc_nln    # Space, Tab, Newline
        tc_tilde tc_fslash      # Tilde, Forward-slash

        # Values for IFS assignment.
        IFS_DEF                 # Default IFS
        IFS_TAN                 # Break on Tab/Newline
        IFS_NLN                 # Break only on Newline
        IFS_RGX                 # Glob using pipe '|'

        typ dir cmd file

    )
    # List of exported local strings.
    declare vars_slx=( IFS )
    # List of local arrays.
    declare vars_al_=( typs dirs cmds cmd_typs )
    # List of local integers.
    declare vars_il_=( fnc_return I J K )
    # List of all local variables.
    declare vars____=( ${vars_sl_[*]} ${vars_slx[*]} ${vars_al_[*]} ${vars_il_[*]} )
    # Declare variables.
    declare     ${vars_sl_[*]}
    declare  -x ${vars_slx[*]}
    declare -a  ${vars_al_[*]}
    declare -i  ${vars_il_[*]}

    fnc="${FUNCNAME[0]}"    # This function.
    fnc_return=0            # Return code for this function.

    # Assign various delimiters for IO
    printf -v tc_spc    ' '
    printf -v tc_tab    '\t'
    printf -v tc_nln    '\n'
    printf -v tc_tilde  '~'
    printf -v tc_fslash '/'
    printf -v IFS_DEF   ' \t\n'
    printf -v IFS_TAN   '\t\t\n'
    printf -v IFS_NLN   '\n\n\n'
    printf -v IFS_RGX   '|\t\n'
    IFS="${IFS_DEF}"

    # Default types of commands for BASH.
    typs=( alias keyword function builtin file )

    # Break on newline only.
    IFS="${IFS_NLN}"

    # Array of command paths.
    dirs=( ${PATH//:/${tc_nln}} )

    # Use completion capability to generate list of commands.
    cmds=( $( compgen -A command ) )

    # Reset IFS to default.
    IFS="${IFS_DEF}"

    # For each command found ..
    for cmd in "${cmds[@]}"
    do

        # .. find all known types.
        cmd_typs=( $( type -at "${cmd}" ) )

        # This function is only concerned with overrides ( i.e. duplicates )
        [ "${#cmd_typs[@]}" -gt 1 ] || continue

        # Show what command we're looking at.
        printf %s "${cmd}"

        for typ in "${typs[@]}"
        do

            # For all types other than 'file', simply show that any entry was found ..
            [ "${typ}" == "file" ] || {
                [[ ! "${cmd_typs[*]}" =~ ^(.* )?${typ}( .*)?$ ]] \
                    || printf '\t%s' "${typ}"
                # .. then continue to the next entry.
                continue
            }

            # Once we find 'file' types, move on to the next stage.
            break

        done

        # If the last type found was 'file', then let's find them.
        [ "${typ}" != "file" ] || {

            # For each directory in our PATH ..
            for dir in "${dirs[@]}"
            do

                file="${dir}/${cmd}"

                # .. show any entry for the current command.
                # ( further, if in home-dir, shorten/anonymize the entry. )
                [ -d "${file}" -o ! -r "${file}" -o ! -x "${file}" ] \
                    || printf '\t%s' "${dir/#${HOME}${tc_fslash}/${tc_tilde}${tc_fslash}}"

            done

        }

        # New is always better! ;P
        printf '\n'

    done

    return "${fnc_return:-0}"

}
