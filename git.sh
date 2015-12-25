#! /dev/null/bash

function gitp ()
{ git pull "${@}"; }

function gitP ()
{ git push "${@}"; }

function gita ()
{ git add "${@}"; }

function gitd ()
{ git diff "${@}"; }

function gits ()
{ git status -sb "${@}"; }

function gitc ()
{ git commit "${@}"; }

function gitC ()
{
    
    declare tmps tmp rgx tc_tab

    printf -v tc_tab    '\t'

    rgx='^([^[:blank:]]*).*[[:blank:]]git commit -m "([^"]*)"'

    for tmp in $( compgen -c gitC )
    do
        [[ "${tmp}" != gitC ]] || continue
        tmp="$( declare -f "${tmp}" )"
        [[ "${tmp}" =~ ${rgx} ]] || continue
        printf '%s\t%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    done

}

function gitC0 ()
{ git commit -m "lazy.. no notes" "${@}"; }

function gitC1 ()
{ git commit -m "meh.. whitespace" "${@}"; }

function gitC3 ()
{ git commit -m "code comments" "${@}"; }

function gitC4 ()
{ git commit -m "restructuring" "${@}"; }

function git_remote_origin_url_open ()
{ git_remote___url_open origin "${@}"; }

function git_remote_upstream_url_open ()
{ git_remote___url_open upstream "${@}"; }

function git_remote___url_open ()
{
    declare vars=(
        dirs dir
        src
        url
        typ
    )
    declare ${vars[*]}
    typ="${1}"
    shift
    dirs=( "${@}" )
    [ "${#@}" -gt 0 ] || dirs=( . )
    for dir in "${dirs[@]}"
    do
        src="$( git config remote.${typ}.url )"
        printf "# %s\t= %s\t@ " "${dir}" "${src}"
        [[ "${src}" =~ ^([^@]*)@([^:/]*):(.*)$ ]] \
            && url="https://${BASH_REMATCH[2]}/${BASH_REMATCH[3]%.git}"
        printf "%s\n" "${url}"
        [ -z "${url}" ] || {
            open "${url}"
            continue
        }
        printf "  Did not open URL\n"
    done
}

function git_display_ignored ()
{
    declare tc_tab
    printf -v tc_tab '\t'
    git ls-files --others |
        git check-ignore --verbose --stdin |
        sed "s/:/${tc_tab}/;s/:/${tc_tab}/" |
        { [ -t 1 ] && column -ts"${tc_tab}" || cat -; }
}

function git_remote_add_origin_push ()
{
    git remote add origin "${1}"
    git push -u origin master
}
