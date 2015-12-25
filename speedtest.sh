#! /dev/null/bash

function speedtest_cli_via_en1 ()
{
    declare en1_ip="$( ifconfig en1 )"
    [[ "${en1_ip}" =~ .*[[:blank:]]inet[[:blank:]]+([0-9\.]*).* ]] || {
        printf '%s\n' "No IP for EN1"
        return 1
    }
    en1_ip="${BASH_REMATCH[1]}"
    speedtest-cli ${en1_ip:+--source ${en1_ip}} "${@}"
}
