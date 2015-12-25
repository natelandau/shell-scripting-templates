#! /dev/null/bash

function pip_pypy_upup ()
{ pip_upup "${@}"; }

function pip_pypy3_upup ()
{ pip_upup "${@}"; }

function pip3_upup ()
{ pip_upup "${@}"; }

function pip_upup ()
{

    local IFS fnc pipc pkgs pkg tmp I

    fnc="${FUNCNAME[1]:-${FUNCNAME[0]}}"
    pipc=( ${fnc%_upup} --disable-pip-version-check )
    printf -v IFS   ' \t\n'

    {

        printf -v IFS   '\n'
        pkgs=(
            $(
                "${pipc[@]}" list -o
#                {
#                    { "${pipc[@]}" list -e | grep .; } \
#                        && { "${pipc[@]}" list -o | egrep '^(pip|setuptools) '; } \
#                        || { "${pipc[@]}" list -o; };
#                } 2>/dev/null
            )
        )
        printf -v IFS   ' \t\n'

        if [[ "${#pkgs[@]}" -gt 0 ]]; then

            printf "${fnc}: Proposed Updates..\n"
            printf '  %s\n' "${pkgs[@]}"
            printf "${fnc}: Install Updates? "
            read -p '' tmp

            if [[ "${tmp}" == [Yy]* ]]; then

                printf "${fnc}: Installing Updates\n"
                for pkg in "${pkgs[@]}"
                do
                    if [[ "${pkg}" =~ \(Current:.*Latest:.*\) ]]; then
                        printf "\n${fnc}: %s\n" \
                            "Installing ${pkg}"
                        "${pipc[@]}" install -U "${pkg%% *}" 2>&1 |
                            egrep \
                                -e '^Requirement already up-to-date:' \
                                -e '^[[:blank:]]*Using cached' \
                                -e '^[[:blank:]]*Found existing installation:' \
                                -e '^[[:blank:]]*Uninstalling .*:' \
                                -v
                    elif [[ "${pkg}" =~ \(.*,.*\) ]]; then
                        printf '\n%s\n' "${pipc[0]}"' -v list -o 2>&1 | less -isR -p '"${pkg%% *}"
                    else
                        printf "${fnc}: %s\n" \
                            "ERROR: ${pkg}"
                    fi
                done

                printf -v IFS   '\n'
                #pkgs=( $( { "${pipc[@]}" list -e | grep -q . || "${pipc[@]}" list -o; } 2>/dev/null ) )
                pkgs=( $( "${pipc[@]}" list -o ) )
                printf -v IFS   ' \t\n'

                if [[ "${#pkgs[@]}" -gt 0 ]]; then
                    printf "\n${fnc}: Still Outdated\n"
                    printf '  %s\n' "${pkgs[@]}"
                fi

            fi

        else

            printf "${fnc}: No Outdated Packages\n"

        fi

    } 1>&2

}

function pip_list_vers ()
{
    local pkg
    for pkg in "${@}"
    do
        printf '%s # ' "${pkg}"
        pip install "${pkg}"==_ 2>&1 | sed -n 's/, / /g;s/^[[:blank:]]*Could not find a version that satisfies the requirement .*==_ (from versions: \(.*\)).*/\1/p'
    done
}
