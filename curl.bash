#! /dev/null/bash

function curl_cookies_ff_upup ()
{

    declare file_cookies ff_profile

    file_cookies=~/.curl/cookies_ff
    ff_profile="$(
        find \
                ~/Library/"Application Support"/Firefox/Profiles/*.default/. \
                -maxdepth 0 \
                -type d \
                -print0 |
            xargs -0 ls -1drt |
            tail -1
    )"

    command cp -af "${file_cookies}"{,.0}

    echo sqlite3 \
            -separator "$( printf '\t' )" \
            "${ff_profile}/cookies.sqlite" \
            'select host, "TRUE", path, case isSecure when 0 then "FALSE" else "TRUE" end, expiry, name, value from moz_cookies'

    return

    sqlite3 \
            -separator "$( printf '\t' )" \
            "${ff_profile}/cookies.sqlite" \
            'select host, "TRUE", path, case isSecure when 0 then "FALSE" else "TRUE" end, expiry, name, value from moz_cookies' \
            > "${file_cookies}".1
    cat "${file_cookies}".[01] |
        grep --color=auto -n . |
        sort -t: -k 2,99 -k 1,1gr |
        sort -t: -k 2,99 -u |
        sort -t: -k 1,1g |
        cut -d: -f2- \
        > "${file_cookies}".9

    diff "${file_cookies}"{,.9}

    command cp -f "${file_cookies}"{.9,}

    command rm -f "${file_cookies}".?

}
