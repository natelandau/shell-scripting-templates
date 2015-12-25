#! /dev/null/bash

function urlenc ()
{

    declare {TAB,NEW,OLD}=
    printf -v TAB "\t"
    #declare LC_ALL="${LC_ALL:-C}"

    OLD="${*}"
    #printf "\n: OLD : %5d : %s\n" "${#OLD}" "${OLD}" 1>&2

    for (( I=0; I<${#OLD}; I++ ))
    do
        C="${OLD:${I}:1}"
        unset H
        case "${C}" in
            ( " " ) { printf -v H "+"; } ;;
            ( [-=\+\&_.~a-zA-Z0-9:/\?\#] ) { printf -v H %s "${C}"; } ;;
            ( * ) { printf -v H "%%%02X" "'${C}"; }
        esac
        NEW+="${H}"
    done

    #printf "\n: NEW : %5d : %s\n\n" "${#NEW}" "${NEW}" 1>&2
    echo "${NEW}"

}

function urldec ()
{

    declare ent enc

    for ent in "${@}"
    do
        enc="$( echo "${ent}" | sed "y/+/ /;s/%25/%/g;s/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g" )"
        printf "${enc}"
    done
}
