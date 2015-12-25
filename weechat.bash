#! /dev/null/bash

function weechat_INIT ()
{

    : ${WEECHAT_HOME_DIR:=~/.weechat}
    : ${WEECHAT_LOG_DIR:=${WEECHAT_HOME_DIR}/logs}

    declare IFS fnc ents ent typ tmp
    printf -v IFS   ' \t\n'
    fnc="${FUNCNAME}"
    ents=(
        WEECHAT_HOME_DIR
        WEECHAT_LOG_DIR
    )

    for ent in "${ents[@]}"
    do
        printf -v tmp 'tmp="${%s}"' "${ent}"
        eval "${tmp}"
        if [[ -r "${tmp}" ]]
        then
            export "${ent}"
        else
            printf "${fnc}: %s\n" \
                    "Could not find ${ent} ( ${tmp} )!"
            return 1
        fi
    done 1>&2

}

function weechat_logs () 
{

    declare vars____=(
        IFS
        tc_tab
        flg_file1
        age
        grep_args
        log_dir
    )
    declare ${vars____[*]}

    weechat_INIT

    printf -v IFS       ' \t\n'
    printf -v tc_tab    '\t'
    flg_file1=1
    [[ -t 1 ]] || flg_file1=0

    log_dir="${WEECHAT_LOG_DIR}"

    age="${1:-1}"
    [ "${#}" -eq 0 ] || shift
    [ "${#}" -eq 0 ] \
        && grep_args=( -w $( date "+%Y-%m-%d" ) ) \
        || grep_args=( "${@}" )

    find "${log_dir}" -mmin -$(( age * 24 * 60 )) -type f -name "*.weechatlog" -print0 |
        xargs -0 grep -Hn "${grep_args[@]}" |
        sed \
                -e :FIX \
                -e "s=${tc_tab}${tc_tab}=${tc_tab}.${tc_tab}=;tFIX" \
                -e "s=^${log_dir}/==" \
                -e "s=^\([^/]*\)/\([^/]*\)/\([^/]*\)/\([^/]*\)\.weechatlog:\([0-9]*\):=\1${tc_tab}\2${tc_tab}\3${tc_tab}\4${tc_tab}\5${tc_tab}=" \
                -e "s=^\([^/]*\)/\([^/]*\)/\([^/]*\)\.weechatlog:\([0-9]*\):=\1${tc_tab}\2${tc_tab}.${tc_tab}\3${tc_tab}\4${tc_tab}=" \
                -e :END |
        sort -t"${tc_tab}" -k 6,6 -k 1,1 -k 2,2 -k 3,3 -k 5,5g |
        cut -f1-3,6- |
        { [[ "${flg_file1}" -eq 1 ]] && { column -ts"${tc_tab}" | grep --color "${grep_args[@]}"; } || cat -; }

}

function weechat_log ()
{ weechat_logs 1 ${@:+"${@}"}; }

function weechat_logs_fix ()
{

    local -a logs nlogs dtss
    local -- log  nlog  dts  dtsn dtsl dtsc IFS tc_tab

    printf -v tc_tab '\t'

    dtsn="$( date +%s )"
    dtsn="$( date -r "$(( dtsn - ( 48 * 60 * 60 ) ))" +%Y-%m-%d )"

    printf -v IFS '\n'
    logs=(
        $(
            find \
                ~/.weechat/logs/irc/rtit_rs/\#nebops/. \
                -name "*.weechatlog" \
                -type f \
                -print
        )
    )
    printf -v IFS ' \t\n'

    for log in "${logs[@]}"
    do

        printf -v IFS '\n'
        dtss=(
            $(
                egrep -no '^[0-9]{4}(.[0-9]{2}){5}' "${log}" |
                sed 's=^[[:blank:]]*\([0-9]*\):\(....\).\(..\).\(..\).\(..\).\(..\).\(..\)=\1:\2\3\4:\5\6\7=' |
                sort -t: -k 2,2g -k 1,1gr |
                sort -t: -k 2,2g -u
            )
        )
        printf -v IFS ' \t\n'

        printf '[ %s ]\t{ %s }\n' "${#dtss[@]}" "${log}"
        printf '( %s - %s )\n' "${dtss[0]}" "${dtss[$((${#dtss[@]}-1))]}"

        break
        continue
        dtsl="${dtss[$((${#dtss[@]}-1))]}"
        if [[ "${dtsl}" =~ ([0-9]{4}).([0-9]{2}).([0-9]{2}).([0-9]{2}).([0-9]{2}).([0-9]{2}) ]]; then
            printf -v dtsl %s "${BASH_REMATCH[@]:1}"
        fi
        printf -v IFS '\n'
        dtss=(
            $(
                { printf '%s\n' "${dtss[@]%?????????}" "${dtsn}_DELETE"; } |
                    sort -u |
                    sed '/_DELETE$/,$d'
            )
        )
        printf -v IFS ' \t\n'
        if [[ "${#dtss[@]}" -gt 1 ]]; then
            printf '+ { %s }\t[ %s ]\n' "${log}" "${#dtss[@]}"
            for dts in "${dtss[@]}"
            do
                nlog="${log%/*}/${dts}.weechatlog"
                printf '> { %s }\n' "${nlog}"
                sed -n  "/^${dts}[ T:\._-]/p" "${log}" >> "${nlog}" && \
                sed -i~ "/^${dts}[ T:\._-]/d" "${log}"
                nlogs[${#nlogs[@]}]="${nlog}${tc_tab}${dtsl}"
            done
        else
            #printf '= { %s }\t{ %s }\n' "${log}" "${dtss:-current}"
            nlogs[${#nlogs[@]}]="${log}${tc_tab}${dtsl}"
        fi

    done

}
