#! /dev/null/bash

function declare_vars_diff ()
{

    local \
        ___declare_vars_diff_diff \
        ___declare_vars_diff_snap \
        ___declare_vars_diff_args

    ___declare_vars_diff_args=(
    -BASH_LINENO
    -BASH_REMATCH
    -BASH_SUBSHELL
    -LINENO
    -RANDOM
    -SECONDS
    -_
    )

    ___declare_vars_diff_snap="$(
    declare_vars "${___declare_vars_diff_args[@]}" |
        sed 's/^\(declare  *[^ ]*  *\)/\1=/' |
        sort -t= -k 2,2 |
        sed 's/=//'
    )"

    if [[ "${#___DECLARE_VARS_DIFF_SNAPS[@]}" -lt 1 || "${1}" == "init" ]]; then
        ___DECLARE_VARS_DIFF_SNAPS=( "${___declare_vars_diff_snap}" )
        return 0
    fi

    ___declare_vars_diff_diff="$(
    diff \
        <(
            printf '%s\n' "${___DECLARE_VARS_DIFF_SNAPS[@]}" |
                grep -nw . |
                sed \
                    -e 's/^\([0-9]*\):\(declare  *[^ ]*  *\)/\1=\2=/' \
                    -e 's/^\([0-9]*\):\(unset  *\)/\1=\2=/' \
                    -e :END |
                sort -t= -k 3,3 -k 1,1gr |
                sort -t= -k 3,3 -u |
                sed 's/^[^=]*=//;s/=//'
        ) \
        <( printf '%s\n' "${___declare_vars_diff_snap}" )
    )"

    unset ___declare_vars_diff_snap

    if [[ -z "${___declare_vars_diff_diff}" ]]; then
        return 0
    fi

    printf '%s\n' "${___declare_vars_diff_diff}"

    #printf '%s\n' "${___declare_vars_diff_diff}" |
    #    sed -n \
    #        -e 's/^[<>] declare  *[^ ]*  *\([^=]*\)=.*/\1/p' \
    #        -e 's/^[<>] unset  *\([^ ]*\).*/\1/p' \
    #        -e :END

    ___declare_vars_diff_diff="$(
    printf '%s\n' "${___declare_vars_diff_diff}" |
        sed -n 's/^> //p'
    )"

    ___DECLARE_VARS_DIFF_SNAPS[${#___DECLARE_VARS_DIFF_SNAPS[@]}]="${___declare_vars_diff_diff}"

    return 0

}

declare_vars() {
    #
    local ___declare_vars_vars=(
    ___declare_vars_I
    ___declare_vars_4eval
    ___declare_vars_tmps
    ___declare_vars_tmp
    ___declare_vars_char
    ___declare_vars_nams
    ___declare_vars_nam
    ___declare_vars_opt
    ___declare_vars_flg_array
    ___declare_vars_vals
    ___declare_vars_val
    ___declare_vars_dec
    ___declare_vars_excludes
    )
    local ${___declare_vars_vars[*]}

    ___declare_vars_nams=()
    ___declare_vars_excludes=(
    ${!___DECLARE_VARS_*}
    ${!___declare_vars_*}
    )
    for ___declare_vars_tmp in "${@}"; do
        if [[ "${___declare_vars_tmp}" == -* ]]; then
            ___declare_vars_excludes[${#___declare_vars_excludes[@]}]="${___declare_vars_tmp#-}"
        else
            ___declare_vars_nams[${#___declare_vars_nams[@]}]="${___declare_vars_tmp#+}"
        fi
    done
    ___declare_vars_tmp=
    if [[ "${#___declare_vars_nams[@]}" -eq 0 ]]; then
        for ___declare_vars_char in {A..Z} _ {a..z}; do

            printf -v ___declare_vars_4eval \
                '___declare_vars_tmps=( ${!%s*} )' \
                "${___declare_vars_char}"
            eval "${___declare_vars_4eval}"

            [[ "${?}" -eq 0 && "${#___declare_vars_tmps[@]}" -gt 0 ]] || continue

            ___declare_vars_nams=( "${___declare_vars_nams[@]}" "${___declare_vars_tmps[@]}" )

        done
        ___declare_vars_tmps=()
    fi

    for ___declare_vars_nam in "${___declare_vars_nams[@]}"; do

        [[ " ${___declare_vars_excludes[*]} " != *" ${___declare_vars_nam} "* ]] || continue

        ___declare_vars_opt="$( declare -p "${___declare_vars_nam}" )"
        ___declare_vars_opt="${___declare_vars_opt#declare }"
        ___declare_vars_opt="${___declare_vars_opt%% *}"

        printf -v ___declare_vars_dec \
            '%4s %s=' \
            "${___declare_vars_opt}" \
            "${___declare_vars_nam}"

        if [[ "${___declare_vars_opt}" == *a* ]]; then
            ___declare_vars_flg_array=1
        else
            ___declare_vars_flg_array=0
        fi

        printf -v ___declare_vars_4eval '___declare_vars_vals=( "${%s[@]}" )' "${___declare_vars_nam}"
        eval "${___declare_vars_4eval}"

        if [[ "${#___declare_vars_vals[@]}" -eq 0 ]]; then

            printf -v ___declare_vars_dec \
                '%s()' \
                "${___declare_vars_dec}"

        else

            if [[ "${___declare_vars_flg_array}" -eq 1 ]]; then
                printf -v ___declare_vars_dec \
                    '%s(' \
                    "${___declare_vars_dec}"
            fi

            for (( ___declare_vars_I=0; ___declare_vars_I<${#___declare_vars_vals[@]}; ___declare_vars_I++ ))
            do
                printf -v ___declare_vars_val \
                    '%q' \
                    "${___declare_vars_vals[${___declare_vars_I}]}"
                if [[ "${___declare_vars_val}" != "$'"* ]]; then
                    if [[ "${___declare_vars_val}" == *\\* ]]; then
                        printf -v ___declare_vars_val \
                        '%s' \
                        "${___declare_vars_vals[${___declare_vars_I}]}"
                        printf -v ___declare_vars_val \
                        '%s' \
                        "$( declare -p ___declare_vars_val )"
                        ___declare_vars_val="${___declare_vars_val#*=}"
                    fi
                fi
                if [[ "${___declare_vars_flg_array}" -eq 1 ]]; then
                    printf -v ___declare_vars_val \
                        ' [%s]=%s' \
                        "${___declare_vars_I}" \
                        "${___declare_vars_val}"
                fi
                printf -v ___declare_vars_dec \
                    '%s%s' \
                    "${___declare_vars_dec}" \
                    "${___declare_vars_val}"
            done

            if [[ "${___declare_vars_flg_array}" -eq 1 ]]; then
                printf -v ___declare_vars_dec \
                    '%s )' \
                    "${___declare_vars_dec}"
            fi

        fi

        printf 'declare %s\n' "${___declare_vars_dec}"

    done

}
