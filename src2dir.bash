#! /dev/null/bash

function src2dir ()
{

    local vars_al_=(
        cmds
        bins
        uris
    )
    local vars_sl_=(
        fnc
        src_base
        cmd
        bin
        uri
        dir
        rgx_bins
        rgx_uri
        rgx_uri_to_dir
        tc_spc tc_tab tc_nln
        tc_tilde tc_fslash tc_colon
        IFS IFS_DEF IFS_NLN IFS_RGX
        I J K
    )
    local -- ${vars_sl_[*]}
    local -a ${vars_al_[*]}

    printf -v tc_spc ' '
    printf -v tc_tab '\t'
    printf -v tc_nln '\n'

    printf -v tc_tilde  '~'
    printf -v tc_fslash '/'
    printf -v tc_colon  ':'

    printf -v IFS_DEF ' \t\n'
    printf -v IFS_NLN '\n'
    printf -v IFS_RGX '|'
    IFS="${IFS_DEF}"

    fnc="${FUNCNAME}"

    src_base="${SRC2DIR_BASE:-${HOME_SRC_DIR:-${HOME}/Source}}"

    rgx_uri='(.*@)?(https?|ssh):///?'
    rgx_uri_to_dir='^([^@/]*@)?([^@:/]+:///?)?([^@/:]*@)?(.*)'

    {

        [ -d "${src_base}/." -a -n "${src_base}" ] || {
            printf "${fnc}: %s\n" \
                    "No source base directory. { ${src_base} }" \
                    "Set SRC2DIR_BASE, or create { ~/Source }"
            return 9
        }

        uris=( "${@}" )

        cmds=(
            git
            'git clone "${uri}" .'
            'git status'
            hg
            'hg clone "${uri}" .'
            'hg verify; hg identify; hg status'
            bzr
            'bzr clone "${uri}" .'
            'bzr status'
            svn
            'svn checkout "${uri}" .'
            'svn status'
            cvs
            'cd ..; cvs -d "${uri}" checkout -P .; cd "${dir}"'
            'cvs status'
        )

        for (( I=0; I<${#cmds[@]}; I+=3 ))
        do
            bins[${#bins[@]}]="${cmds[${I}]}:${I}"
        done

        IFS="${IFS_RGX}"
        rgx_bins="${bins[*]%:*}"
        IFS="${IFS_DEF}"

        for uri in "${uris[@]}"
        do

            if [[ "${uri}" =~ ^(${rgx_bins})[@:] ]]; then
                bin="${BASH_REMATCH[1]}"
            elif [[ "${uri}" =~ ^(${rgx_uri})?github\. ]]; then
                bin=git
            elif [[ "${uri}" =~ ^(${rgx_uri})?bitbucket\. ]]; then
                bin=hg
            elif [[ "${uri}" =~ ^(${rgx_uri})?cvsweb\. ]]; then
                bin=cvs
            elif [[ "${uri}" =~ ^(${rgx_uri})?[^/]+/.+\.(${rgx_bins})$ ]]; then
                bin="${BASH_REMATCH[3]}"
            elif [[ "${uri}" =~ ^${rgx_uri}(${rgx_bins}).* ]]; then
                bin="${BASH_REMATCH[3]}"
            else
                printf "${fnc}: %s\n" \
                        "Could not determine source type of URI { ${uri} }"
                continue
            fi

            printf "${fnc}: %s\t%s\n" \
                    'URI'   "${uri}" \
                    'Type'  "${bin}"

            dir="${uri}"

            if [[ "${dir}" =~ ${rgx_uri_to_dir} ]]; then
                dir="${BASH_REMATCH[4]}"
            fi
            #printf "${fnc}: %s\t%s\n" 'Dir?' "${dir}"

            if [[ "${dir}" =~ github.* ]]; then
                dir="${dir%.git}.git"
            fi
            #printf "${fnc}: %s\t%s\n" 'Dir?' "${dir}"

            dir="${src_base}/${bin}/${dir}"
            printf "${fnc}: %s\t%s\n" 'Dir' "${dir/#${HOME}/${tc_tilde}}"

            mkdir -p "${dir}" && cd "${dir}"
            if [[ "${?}" -ne 0 ]]; then
                printf "${fnc}: %s\n" \
                        "Could not prepare target directory!"
                continue
            fi

            for I in "${bins[@]}"
            do

                [[ "${I}" == ${bin}:* ]] || continue

                I="${I#*:}"

                printf "${fnc}: %s\n" "Obtain.."
                cmd=( ${cmds[$((I+1))]} )
                printf "${fnc}: %s\n" "{ $( eval echo "${cmd[@]}" ); }"
                eval "${cmd[@]}"

                [ "${?}" -ne 0 ] || break

                printf "${fnc}: %s\n" "Status.."
                cmd=( ${cmds[$((I+2))]} )
                printf "${fnc}: %s\n" "{ $( eval echo "${cmd[@]}" ); }"
                eval "${cmd[@]}"

                break

            done

        done

    }

}
