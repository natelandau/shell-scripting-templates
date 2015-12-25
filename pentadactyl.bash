#! /dev/null/bin/bash

function ___pentadactyl_common_source ()
{

    declare vars=(
        tmp
        tc_tab
        ent
        cmd
        prv
        val
        dts
    )
    declare ${vars[*]}

    printf -v tc_tab '\t'

    declare -p ${vars[*]}

}

function ___pentadactyl_history_dts ()
{

    eval "$( ___pentadactyl_common_source )"

    while read -r ent
    do
        dts="${ent%%${tc_tab}*}"
        dts="${dts%??????}"
        date -j -f %s "+%Y-%m/%d %H:%M:%S" "${dts}" 2>/dev/null || echo _ERR_
        echo "${ent}"
    done |
        paste - -

}

function pentadactyl_history_commands ()
{

    eval "$( ___pentadactyl_common_source )"

    declare {tmp,ent,cmd,prv,val,dts}=
    tmp="${TMPDIR:-/tmp}/.pentadactyl.history.tmp"
    find "${tmp}" -mmin +1 -ls -exec rm -f "{}" \; 1>&2 2>/dev/null
    [ -f "${tmp}" ] || {
        for ent in ~/.pentadactyl/info/*/command-history
        do
            json2path < "${ent}" >> "${tmp}"
        done
    }
    while read -r ent
    do
        [[ "${ent}" =~ ^/command\[([0-9]+)\]/(privateData|value|timestamp)=(.*) ]] || continue
        [ "${BASH_REMATCH[1]}" == "${cmd}" ] || { cmd="${BASH_REMATCH[1]}"; prv=; val=; dts=; }
        case "${BASH_REMATCH[2]}" in
            ( privateData ) prv="${BASH_REMATCH[3]}";;
            ( value )       { val="${BASH_REMATCH[3]%\"}"; val="${val#\"}"; } ;;
            ( timestamp )   dts="${BASH_REMATCH[3]}";;
        esac
        [ -z "${prv}" -o -z "${val}" -o -z "${dts}" ] || printf "%s\t%s\t%s\n" "${dts}" "${prv}" "${val}"
    done < "${tmp}"
}

function pentadactyl_history_commands_dts ()
{ pentadactyl_history_commands | ___pentadactyl_history_dts; }

function pentadactyl_history_sets ()
{

    eval "$( ___pentadactyl_common_source )"

    pentadactyl_history_commands |
    sed -n "s/\(${tc_tab}set[^=]*\)=\(..*\)/\1${tc_tab}\2/p" |
    sort -t"${tc_tab}" -k 1,1g |
    sed "s/\(${tc_tab}set[^${tc_tab}]*\)${tc_tab}/\1=/"
}

function pentadactyl_history_sets_dts ()
{ pentadactyl_history_sets | ___pentadactyl_history_dts; }

function pentadactyl_history_sets_latest ()
{

    eval "$( ___pentadactyl_common_source )"

    pentadactyl_history_sets |
    sed -n "s/\(${tc_tab}set[^=]*\)=/\1${tc_tab}/p" |
    sort -t"${tc_tab}" -k 3,3 -k 1,1gr |
    sort -ut"${tc_tab}" -k 3,3 |
    sort -t"${tc_tab}" -k 1,1g |
    sed "s/\(${tc_tab}set[^${tc_tab}]*\)${tc_tab}/\1=/"
}

function pentadactyl_history_sets_latest_dts ()
{ pentadactyl_history_sets_latest | ___pentadactyl_history_dts; }

function pentadactyl_plugins_activate ()
{
    declare ENT
    cd ~/.pentadactyl/plugins/load/ || return 1
    for ENT in $( find ../../plugins_* -type f -a -name "*.js" -a -print )
    do
        {
            printf "\n### %s ###\n\n" "${ENT#*/plugins_}"
            read -p "? " -n1
            echo
            [[ "${REPLY}" != [yY] ]] || ln -vnfs "${ENT}"
        } 1>&2
    done
}
