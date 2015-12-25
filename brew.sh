#! /dev/null/bash

#function brew ()
#{
#
#    #
#    # Clean run of Homebrew
#    #
#
#    # Obtain Homebrew prefix.
#    declare prefix="$( command brew --prefix )"
#
#    # Only change PATHs for this function and any sub-procs
#    declare -x PATH MANPATH
#
#    # Reset PATHs
#    eval "$( PATH= MANPATH= /usr/libexec/path_helper -s )"
#
#    # Add Homebrew PATHs
#    PATH="${prefix}/bin:${prefix}/sbin:${PATH}"
#    MANPATH="${prefix}/man:${MANPATH}"
#
#    # Run Homebrew
#    hash -r
#    command brew "${@}"
#
#}

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

# brew uninstall/install (actual-reinstall)
function brewR ()
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

    ( "R"  ) {
             brew uninstall  "${args[@]}"
             brew install    "${args[@]}"
             };;

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
        { [ "${#results[@]}" -lt ${LINES:-0} ] && cat - || less -isR; }

}

function brew_stat ()
{

    #
    # Brew package status.
    # Modeled after output of aptitude
    #

    declare -x IFS
    declare -a brews_ents brewl_ents
    declare    tc_tab ent

    printf -v tc_tab '\t'
    printf -v IFS    '\n'

    for ent in "${@}"
    do
        brews_ents=( "${brews_ents[@]}" $( brew search "${ent}" ) )
    done

    for ent in "${brews_ents[@]}"
    do
        brewl_ents=( "${brewl_ents[@]}" $( brew list | grep -i "${ent}" ) )
    done

    comm <( printf '%s\n' "${brews_ents[@]}" ) <( printf '%s\n' "${brewl_ents[@]}" ) |
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
            [[ "${REPLY}" != [Yy] ]] || brew upgrade --all
        } || {
            printf "No outdated brews.\n"
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
            printf "No brews to cleanup.\n"
        }

    } 1>&2

}

function brew_via_proxy ()
{ proxychains4 -q brew "${@}"; }

function brew_linkapps_fix ()
{
    declare IFS apps app applnk lnk
    printf -v IFS '\t'
    printf '\n# Generating Apps List and Updating Links ..\n'
    apps=($( brew linkapps 2>&1 | grep -o '[^/]*\.app' | sort -u | tr '\n' '\t' ))
    printf -v IFS ' \t\n'
    apps=("${apps[@]/#//Applications/}")
    printf '\n'
    for app in "${apps[@]}"
    do
        [[ -z "${app}" || ! -e "${app}" ]] || {
            printf '# Removing .. %s\n' "${app}"
            rm -i -rf "${app}"
        }
    done
    printf '\n# Generating Apps Links ..\n'
    brew linkapps
    for app in "${apps[@]}"
    do
        printf '\n'
        applnk="${app}.linkapps_fix"
        printf '# Moving link .. %s\n' "${applnk}"
        rm -i -f "${applnk}"
        mv -i -vf "${app}" "${applnk}"
        lnk="$( ls -lond "${applnk}" | sed -n 's=.* -> ==p' )"
        printf '# Generating Fixed Links .. %s .. %s\n' "${app}" "${lnk}"
        mkdir "${app}"
        ln -vnfs "${lnk}"/* "${app}"/
        chmod -R a+rx "${app}"
        printf '# Removing .. %s\n' "${applnk}"
        rm -i -vf "${applnk}"
    done
}

function brew_UNINSTALL ()
{

    declare fnc ents ent
    fnc="${FUNCNAME}"
    ents=(
        Library/Aliases
        Library/Contributions
        Library/Formula
        Library/Homebrew
        Library/LinkedKegs
        Library/Taps
        .git
        '~/Library/*/Homebrew'
        '/Library/Caches/Homebrew/*'
    )

    hash -r
    export HOMEBREW_PREFIX
    HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$( brew --prefix )}"

    {

        if [[ -n "${HOMEBREW_PREFIX}" ]]; then
            cd "${HOMEBREW_PREFIX}"/. >/dev/null 2>&1
            if [[ "${?}" -ne 0 ]]; then
                printf "${fnc}: %s\n" \
                    "ERROR: Could not change directory { ${HOMEBREW_PREFIX} }"
            fi
        else
            printf "${fnc}: %s\n" \
                "ERROR: Could not determine HOMEBREW_PREFIX"
        fi

        if [[ -e Cellar/. ]]; then
        printf "${fnc}: %s\n" \
            "Removing Cellar"
        command rm -rf Cellar || return 255
        fi

        if [[ -x bin/brew ]]; then
            printf "${fnc}: %s\n" \
                "Brew Pruning"
            bin/brew prune || return 254
        fi

        if [[ -d .git/. ]]; then
            printf "${fnc}: %s\n" \
                "Removing GIT Data"
            git checkout -q master || return 253
            { git ls-files | tr '\n' '\0' | xargs -0 rm -f; } || return 252
        fi

        for ent in "${ents[@]}"
        do
            [[ -n "${ent}" ]] || continue
            if [[ $( eval ls -1d "${ent}" >/dev/null 2>&1 ) ]]; then
            printf "${fnc}: %s\n" \
                "Removing { ${ent} }"
            eval command rm -rf "${ent}"
            fi
        done

            printf "${fnc}: %s\n" \
                "Removing Broken SymLinks"
        find -L . -type l -exec rm -- {} +
            printf "${fnc}: %s\n" \
                "Removing Empty Dirs"
        find . -depth -type d -empty -exec rmdir -- '{}' \; 2>/dev/null

    } 1>&2

}

function brew_INSTALL ()
{

    local fnc precmd cmderr umask_bak
    fnc="${FUNCNAME}"
    precmd=
    cmderr=0
    umask_bak="$( umask )"
    umask 0002

    {

        printf "${fnc}: %s\n" "Setting up { /usr/local }"
        while :; do
            {
                "${precmd[@]}" mkdir -p           /usr/local/bin
                "${precmd[@]}" chgrp -R admin     /usr/local/.
                "${precmd[@]}" chmod -R g+rwX,o+X /usr/local/.
                #"${precmd[@]}" find               /usr/local/. -type d -exec chmod g+s '{}' \;
            } 2>/dev/null
            cmderr="${?}"
            if [[ "${cmderr}" -gt 0 ]]; then
                if [[ "${precmd[0]}" == 'sudo' ]]; then
                    printf "${fnc}: %s\n" \
                        "ERROR: Could not setup { /usr/local }"
                    return 255
                else
                    precmd=( sudo -p "${fnc}: Need administrator privileges: " )
                    continue
                fi
            fi
            break
        done

        printf "${fnc}: %s\n" \
            "Status of involved directories."
        ls -ld /usr/local/. /usr/local/*

        printf "${fnc}: %s\n" \
            "Install Homebrew."
        ruby -e "$(
            curl -fL 'https://raw.githubusercontent.com/Homebrew/install/master/install'
        )"
#        curl -L https://github.com/Homebrew/homebrew/tarball/master |
#            tar xz --strip 1 -C "${prefix}"

#        printf "${fnc}: %s\n" \
#            "Create symlink for { brew }."
#        ln -vnfs "${prefix}/bin/brew" /usr/local/bin/brew
#
#        printf "${fnc}: %s\n" \
#            "Update Homebrew."
#        /usr/local/bin/brew update

        umask "${umask_bak}"

    } 1>&2

}

function brew_BACKUP ()
{
    local fnc tc_tab tc_nln tc_tilde pkgs pkg opti optu out tmp rgx IFS IFS_DEF IFS_NLN
    printf -v tc_tab    '\t'
    printf -v tc_nln    '\n'
    printf -v tc_tilde  '~'
    printf -v IFS_DEF   ' \t\n'
    printf -v IFS_NLN   '\n'
    IFS="${IFS_DEF}"
    fnc="${FUNCNAME}"
    out=~/Documents/brew_BACKUP_"$( date +%Y_%m_%d_%H_%M_%S )".txt
    tmp="$(
        brew info --json=v1 --installed |
            jq -c '.[] | { ( .name ): .dependencies }' |
            sed \
                -e 's="[^"]*/\([^"]*\)"="\1"=g' \
                -e :END
    )"
    rgx="$(
        echo "${tmp}" |
            sed \
                -e = \
                -e 's=^{\([^:]*\)\(.*\)}=s'"${tc_tab}"'\1\\([^:]\\)'"${tc_tab}"'{\1\2}\\1'"${tc_tab}"'=' \
                -e :END |
            sed \
                -e '/^[0-9]*$/bLBL' \
                -e bPRT \
                -e :LBL \
                -e 's/^/:RGX/' \
                -e p \
                -e 's/^:/t/' \
                -e h \
                -e d \
                -e :PRT \
                -e 'p;g' \
                -e :END
    )"
    tmp="$(
        echo "${tmp}" |
            sed -f <( echo "${rgx}" ) |
            grep -o '"[^"]*"' |
            cut -d'"' -f2
    )"
    tmp="$(
        echo "${tmp}" |
            grep -n . |
            sort -t: -k 2,2 -k 1,1gr |
            sort -t: -k 2,2 -u |
            sort -t: -k 1,1gr |
            cut -d: -f2
    )"

    IFS="${IFS_NLN}"
    pkgs=( ${tmp} )
    IFS="${IFS_DEF}"

    brew info --json=v1 "${pkgs[@]}" |
        jq -r '
            .[] |
            .name as $name |
            .installed[].version as $ver |
            (
                (
                    .versions |
                    to_entries |
                    map( select( .value == $ver ) ) |
                    .[].key
                )
                //
                (
                    "version_not_found_" + $ver + "_this_will_install_default"
                )
            ) as $ver |
            (
                if $ver == "head" then
                    "HEAD"
                elif
                    $ver == "stable"
                then
                    null
                else
                    $ver
                end
            ) as $ver |
            [ .installed[].used_options[] ] as $opti |
            ( [ .options[].option ] - $opti ) as $optu |
            [
                "brew install",
                $name,
                ( if $ver then "--" + $ver else empty end ),
                $opti[],
                ( if ( $optu | length ) > 0 then "#", $optu[] else empty end )
            ] |
            join(" ")' |
        tee "${out}"
    printf "${fnc}: %s\n" "Stored in { ${out/${HOME}/${tc_tilde}} }" 1>&2
}

function brew_new ()
{
    local dts="$( date -r $(( $( date +%s ) - ${1:-7} * 24 * 60 * 60 )) +%Y-%m-%d )"
    brew log --grep='(new formula)' --since="${dts}" | sed -n 's/^[[:blank:]]*\([^[:blank:]]*\).*(new formula).*/\1/p' | sort -u
}
