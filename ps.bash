#! /dev/null/bash

function pso ()
{

    local vars_sl_=(
        ps_pad
        ps_fmt
        ps_hdrs
        ps_hdr_left
        ps_lin
        ps_col
        rgx_ps_fmt
        rgx_ps_hdr
        rgx_ps_hdr_hide
        rgx_ps_out_cols
        fnc
        fout
        tmp
        tc_nln tc_tab tc_space
        IFS IFS_DEF IFS_N
    )
    local vars_al_=(
        ps_args
        ps_cmd
        ps_out
        ps_hdr_lens
        ps_hdr_maxs
        ps_cols
    )
    local vars_il_=(
        flg_hdr_hide
        flg_hdr_is
        I J K
    )
    local     ${vars_sl_[*]}
    local -a  ${vars_al_[*]}
    local -i  ${vars_il_[*]}

    {

        printf -v fnc       "${FUNCNAME}"
        printf -v fout      %s "printf ${fnc}:\040%s\n"
        printf -v tc_nln    '\n'
        printf -v tc_tab    '\t'
        printf -v tc_space  '\t'
        printf -v IFS_DEF   ' \t\n'
        printf -v IFS_N     '\n'
        IFS="${IFS_DEF}"

        printf -v ps_pad    '%0*d' 16 0
        ps_pad="${ps_pad//0/_}"
        ps_hdr_left='pgid'

        printf -v rgx_ps_fmt %s \
            '^' \
            "([^${tc_tab}]*,)?" \
            "([^${tc_tab},=]*)" \
            "(=[^${tc_tab},]*)?" \
            '(,.*)?' \
            '$'
        printf -v rgx_ps_hdr %s \
            '^' \
            '[[:blank:]]*' \
            "(${ps_pad}[^[:blank:]]*[[:blank:]]*)" \
            '([[:blank:]].*)?' \
            '$'
        printf -v rgx_ps_hdr_hide %s \
            '^' \
            "[[:blank:]]*${ps_pad}${ps_hdr_left}[[:blank:]_]*" \
            '$'

        ps_fmt="${1}"
        [[ "${#}" -lt 1 ]] || shift
        ps_args=( "${@}" )

        while [[ "${ps_fmt}" =~ ${rgx_ps_fmt} ]]; do
            tmp="${BASH_REMATCH[3]:-=${BASH_REMATCH[2]}}"
            printf -v ps_fmt %s \
                "${BASH_REMATCH[1]}" \
                "${tc_tab}" \
                "${BASH_REMATCH[2]}" \
                "=${ps_pad}${tmp#=}" \
                "${BASH_REMATCH[4]}"
        done
        ps_fmt="${ps_fmt//${tc_tab}}"

        ps_cmd=(
            ps
            -o "${ps_hdr_left}=${ps_pad}${ps_hdr_left}"
            -o "${ps_fmt}"
            "${ps_args[@]}"
        )

        IFS="${IFS_N}"
        ps_out=( $( "${ps_cmd[@]}" ) )
        IFS="${IFS_DEF}"
        ps_out=( "${ps_out[@]//${tc_tab}/ }" )

        ps_hdrs="${ps_out[0]}"
        if [[ "${ps_hdrs}" =~ ${rgx_ps_hdr_hide} ]]; then
            flg_hdr_hide=1
        else
            flg_hdr_hide=0
        fi
        while [[ "${ps_hdrs}" =~ ${rgx_ps_hdr} ]]; do
            ps_hdr_lens[${#ps_hdr_lens[@]}]="${#BASH_REMATCH[1]}"
            ps_hdrs="${BASH_REMATCH[2]}"
        done
        printf -v rgx_ps_out_cols \
            '(.{%s})[[:blank:]]' \
            "${ps_hdr_lens[@]::$((${#ps_hdr_lens[@]}-1))}"
        rgx_ps_out_cols='^'"${rgx_ps_out_cols}"'(.*)$'

        ps_hdrs="${ps_out[0]}"

        for (( I=0; I<${#ps_out[@]}; I++ )); do
            ps_lin="${ps_out[${I}]}"
            if [[ "${ps_lin}" =~ ${rgx_ps_out_cols} ]]; then
                printf '{%s} ' "${BASH_REMATCH[@]:1:$((${#BASH_REMATCH[@]}-2))}"
                printf '{%s}\n' "${BASH_REMATCH[$((${#BASH_REMATCH[@]}-1))]}"
                ps_cols=( "${BASH_REMATCH[@]:1:$((${#BASH_REMATCH[@]}-1))}" )
                for (( J=0; J<${#ps_cols[@]}; J++ )); do
                    ps_col="${ps_cols[${J}]}"
                    if [[ "${J}" -eq 0 && "${ps_col}" =~ ^${ps_pad}${ps_hdr_left}$ ]]; then
                        flg_hdr_is=1
                    else
                        flg_hdr_is=0
                    fi
                done
            else
                $fout "ERROR: RegEx Failure [ ${?} ] on.." "{{{ ${lin} }}}"
            fi
        done

    } 1>&2

    #printf '%s\n' "${ps_out[@]}"

}
