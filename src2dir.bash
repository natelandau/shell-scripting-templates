#! /dev/null/bash

function src2dir ()
{

    declare vars=(
        fnc
        src_repo
        cmds cmd
        bins bin
        uris uri
        dir
        rgx_bins
        rgx_uri_to_dir
        tc_spc tc_tab tc_nln
        tc_tilde tc_fslash tc_colon
        IFS IFS_O_RGX IFS_I_ALL IFS_I_TAN IFS_I_NLN
        I J K
    )
    declare ${vars[*]}

    cmds=()
    bins=()
    uris=()

    fnc="${FUNCNAME}"

    src_repo="${SRC2DIR_REPO:-${HOME}/.src}"
    [ -d "${src_repo}/." -a -n "${src_repo}" ] || {
        printf "${fnc}: %s\n" \
                "Could not find source target directory environment variable SRC2DIR_REPO or { ~/.src }"
        return 9
    }

    printf -v tc_spc ' '
    printf -v tc_tab '\t'
    printf -v tc_nln '\n'

    printf -v tc_tilde  '~'
    printf -v tc_fslash '/'
    printf -v tc_colon  ':'

    printf -v IFS_I_ALL ' \t\n'
    printf -v IFS_I_TAN '\t\t\n'
    printf -v IFS_I_NLN '\n\n\n'
    printf -v IFS_O_RGX '|\t\n'
    IFS="${IFS_I_ALL}"

    uris=( "${@}" )

    cmds=(
        git     'git clone "${uri}" .'                                  'git status'
        hg      'hg clone "${uri}" .'                                   'hg verify; hg identify; hg status'
        bzr     'bzr clone "${uri}" .'                                  'bzr status'
        svn     'svn checkout "${uri}" .'                               'svn status'
        cvs     'cd ..; cvs -d "${uri}" checkout -P .; cd "${dir}"'     'cvs status'
    )

    for (( I=0; I<${#cmds[@]}; I+=3 ))
    do
        bins=( "${bins[@]}" "${cmds[${I}]}:${I}" )
    done

    IFS="${IFS_O_RGX}"
    rgx_bins="${bins[*]%:*}"
    IFS="${IFS_I_ALL}"

    rgx_uri_to_dir='^([^@/]*@)?([^@:/]+:///?)?([^@/:]*@)?(.*)'

    for uri in "${uris[@]}"
    do

        bin=

        [[ -n "${bin}" || ! "${uri}" =~ ^(${rgx_bins})[@:] ]] \
            || bin="${BASH_REMATCH[1]}"
        [[ -n "${bin}" || ! "${uri}" =~ (.*@)?(https?|ssh):///?(${rgx_bins})[\.@/] ]] \
            || bin="${BASH_REMATCH[3]}"
        [[ -n "${bin}" || ! "${uri}" =~ ((.*@)?(https?|ssh):///?)?github\. ]] \
            || bin=git
        [[ -n "${bin}" || ! "${uri}" =~ ((.*@)?(https?|ssh):///?)?bitbucket\. ]] \
            || bin=hg
        [[ -n "${bin}" || ! "${uri}" =~ ((.*@)?(https?|ssh):///?)?cvsweb\. ]] \
            || bin=cvs
        [[ -n "${bin}" || ! "${uri}" =~ (.*@)?(https?|ssh):///?[^/]+/.+\.(${rgx_bins})$ ]] \
            || bin="${BASH_REMATCH[3]}"
        [[ -n "${bin}" || ! "${uri}" =~ .*/(${rgx_bins})(/.*)?$ ]] \
            || bin="${BASH_REMATCH[1]}"
        [[ -n "${bin}" || ! "${uri}" =~ /(cvsroot|cvsweb|cvs)/ ]] \
            || bin=cvs
        [[ -n "${bin}" || ! "${uri}" =~ \.(${rgx_bins})\. ]] \
            || bin="${BASH_REMATCH[1]}"

        [ -n "${bin}" ] || {
            printf "${fnc}: %s\n" \
                    "Could not determine source type of URI { ${uri} }"
            continue
        } 1>&2

        printf "${fnc}: %s\n" \
                "URI   ${uri}" \
                "Type  ${bin}"

        dir="${uri}"

        [[ ! "${dir}" =~ ${rgx_uri_to_dir} ]] \
            || dir="${BASH_REMATCH[4]}"

        dir="${dir//${tc_colon}${tc_fslash}/${tc_fslash}}"
        dir="${dir%/}"
        dir="${dir//:/${tc_fslash}}"
        dir="${src_repo}/${dir}"

        printf "${fnc}: %s\n" "Dir   ${dir/#${HOME}/${tc_tilde}}"

        mkdir -p "${dir}" && cd "${dir}" || {
            printf "${fnc}: %s\n" \
                    "Could not prepare target directory!"
            continue
        } 1>&2

        for I in "${bins[@]}"
        do

            [[ "${I}" == ${bin}:* ]] || continue

            I="${I#*:}"

            printf "${fnc}: %s\n" "Obtain.."
            cmd=( ${cmds[$((I+1))]} )
            #printf '{%q}\n' "${cmd[@]}"
            eval "${cmd[@]}"

            [ "${?}" -ne 0 ] || break

            printf "${fnc}: %s\n" "Status.."
            cmd=( ${cmds[$((I+2))]} )
            #printf '{%q}\n' "${cmd[@]}"
            eval "${cmd[@]}"

            break

        done

    done

}
