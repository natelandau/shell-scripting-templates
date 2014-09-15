#! /dev/null/bash

function brew ()
{

    #
    # Reset PATHs for clean run of Homebrew
    #

    # Only change PATHs for this function and any sub-procs
    declare -x PATH MANPATH

    # Reset PATHs
    eval "$( PATH= MANPATH= /usr/libexec/path_helper -s )"

    # Run Homebrew
    command brew "${@}"

}

function brew_actioner ()
{
    #
    # Run Homebrew ( brew ) commands via shortcuts,
    #   or 'smarter' invocations.
    #

    declare vars=(

        fnc         # Function name, for errors, etc.
        fnc_msg     # Message code for function.
        fnc_return  # Return code for function.

        act         # Action ( What brew is being asked to do. )
        args arg    # Arguments provided to these functions.
        tmp         # General termporary variable.
        results     # Output of invoked brew commands.

        IFS         # Override default shell IFS, for manipulation of IO.

                    # TERM codes for display enhancement.
        tc_rst      # Reset
        tc_rev      # Reverse

    )
    declare ${vars[*]}

    # Delimit IO on newline only.
    printf -v IFS '\n\n\n'

    # What was brew_actioner *called* as?
    fnc="${FUNCNAME[1]}"
    # What action was requested?
    act="${fnc#brew}"
    # Store arguments to calling function.
    args=( "${@}" )
    # Init 'results' and 'tmp' as arrays.
    results=()
    tmp=()

    # Message code for function.
    fnc_msg=( printf "${fnc}: %s\n" )

    # Execute brew actions..

    case "${act}" in

    # These actions are just simple shortcuts.
    # No output manipulation.

    ( "I"  ) brew install    "${args[@]}";;

    ( "U"  ) brew uninstall  "${args[@]}";;

    ( "u"  ) brew update     "${args[@]}";;

    ( "Up" ) brew upgrade    "${args[@]}";;

    ( "h"  ) brew home       "${args[@]}";;

    # Actions where results are stored for further manipulation.

    ( "s" ) {
        results=( $( brew search "${args[@]}" ) )
    };;

    ( "l" ) {
        results=( $( brew list "${args[@]}" ) )
    };;

    # The ouput of 'info' for multiple packages can be hard to read.
    # This just helps out some.
    # It *does* inhibit the use of options to the info action.

    ( "i" ) {
        tc_rev="$( tput rev )"
        tc_rst="$( tput sgr0 )"
        for arg in "${args[@]}"
        do
            tmp=( $( brew info "${arg}" ) )
            tmp[0]="${tc_rev}${tmp[0]}${tc_rst}"
            results=( "${results[@]}" "" "${tmp[@]}" )
            fnc_return="$(( ${fnc_return:-0} + ${?} ))" # Store return codes.
        done
    };;

    # Just in case the actioner gets called with an unknown function/action.

    ( * ) {
        "${fnc_msg[@]}" "Unknown action ( ${act} )" 1>&2
        return 1
    };;

    esac

    # If return value is still null, assign the latest error code.
    [ -n "${fnc_return}" ] || fnc_return="${?}"

    # If no results, then just return from function.
    [ "${#results[@]}" -gt 0 ] || return 0;

    # Print results, using a pager if result count is greater than height of our terminal.
    printf '%s\n' "${results[@]}" |
        { [ "${#results[@]}" -lt ${LINES:-0} ] && cat - || eval "${PAGER:-less -isR}"; }

}

function brew_stat ()
{

    #
    # Brew package status.
    # Modeled after output of aptitude
    #

    declare tc_tab

    printf -v tc_tab '\t'

    comm <( brew search ) <( brew list ) |
    sed \
            -e "s/^${tc_tab}${tc_tab}/i   /;tEND" \
            -e "s/^${tc_tab}/i?  /;tEND" \
            -e "s/^/p   /;tEND" \
            -e :END

}

function brew_upup ()
{

    #
    # Guided update/upgrade/cleanup
    #

    declare tmp=

    {

        # First update brew.
        brew update

        # Any outdated packages found?
        tmp="$( brew outdated )"
        [ -n "${tmp}" ] && {
            # Show outdated packages and confirm upgrade.
            printf "\n"
            brew outdated
            printf "\nUpgrade? [y/N] "
            read -n1
            printf "\n"
            [[ "${REPLY}" != [Yy] ]] || brew upgrade
        } || {
            printf "No outdated brews..\n"
        }

        # Any cleanup needed?
        tmp="$( brew cleanup -n )"
        [ -n "${tmp}" ] && {
            # Show cleanup needed and confirm removal.
            printf "\n%s\n\nCleanup? [y/N] " "${tmp}"
            read -n1
            printf "\n"
            [[ "${REPLY}" != [Yy] ]] || brew cleanup
        } || {
            printf "No brews to cleanup..\n"
        }

    } 1>&2

}

# brew install
function brewI ()
{ brew_actioner "${@}"; }

# brew uninstall
function brewU ()
{ brew_actioner "${@}"; }

# brew update
function brewu ()
{ brew_actioner "${@}"; }

# brew upgrade
function brewUp ()
{ brew_actioner "${@}"; }

# brew home
function brewh ()
{ brew_actioner "${@}"; }

# brew search
function brews ()
{ brew_actioner "${@}"; }

# brew list
function brewl ()
{ brew_actioner "${@}"; }

# brew info
function brewi ()
{ brew_actioner "${@}"; }

