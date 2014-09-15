#! /dev/null/bash

function weechat_log ()
{ weechat_logs 1 ${@:+"${@}"}; }

function weechat_logs () 
{

    declare vars____=(
        log_dir
        age
        grep_args
        logs
        IFS
        tc_tab
    )
    declare ${vars____[*]}

    printf -v IFS '\n\n\n'
    export IFS

    printf -v tc_tab '\t'

    log_dir=~/.weechat/logs

    [ "${#}" -eq 0 ] || {
        age="${1:-1}"
        shift
        grep_args=( "${@}" )
    }
    [ "${#grep_args[@]}" -gt 0 ] || {
        age="${age:-1}"
        grep_args=( -w $( date "+%Y-%m-%d" ) )
    }

    logs=( $(
            find "${log_dir}" -mmin -$(( age * 24 * 60 )) -type f -name "*.weechatlog" -print |
                grep . || echo /dev/null
    ) )

    logs=( $(
            grep -l "${grep_args[@]}" "${logs[@]}" || echo /dev/null
    ) )

    grep -Hn "${grep_args[@]}" "${logs[@]}" |
        sed \
                -e :FIX \
                -e "s=${tc_tab}${tc_tab}=${tc_tab}.${tc_tab}=;tFIX" \
                -e "s=^${log_dir}/==" \
                -e "s=^\([^/]*\)/\([^/]*\)/\([^/]*\)/\([^/]*\)\.weechatlog:\([0-9]*\):=\1${tc_tab}\2${tc_tab}\3${tc_tab}\4${tc_tab}\5${tc_tab}=" \
                -e "s=^\([^/]*\)/\([^/]*\)/\([^/]*\)\.weechatlog:\([0-9]*\):=\1${tc_tab}\2${tc_tab}.${tc_tab}\3${tc_tab}\4${tc_tab}=" \
                -e :END |
        sort -t"${tc_tab}" -k 6,6 -k 1,1 -k 2,2 -k 3,3 -k 5,5g |
        cut -f1-3,6- |
        { [ -t 1 ] && { column -ts"${tc_tab}" | grep --color "${grep_args[@]}"; } || cat -; }

}
