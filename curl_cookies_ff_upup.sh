#! /dev/null/bash

function curl_cookies_ff_upup ()
{

    local -- tc_htab
    local -- file_cookies ff_profile

    printf -v tc_htab '\t'

    file_cookies=~/.curl/cookies_ff
    mkdir -p "${file_cookies%/*}"
    ff_profile="$(
        find \
                ~/Library/"Application Support"/Firefox/Profiles/*.default/. \
                -maxdepth 0 \
                -type d \
                -print0 \
                | xargs -0 ls -1drt \
                | tail -1
    )"

    command cp -af "${file_cookies}"{,.0} 2>/dev/null

            #'select host, "TRUE", path, case isSecure when 0 then "FALSE" else "TRUE" end, expiry, name, value from moz_cookies'
    sqlite3 \
            -separator "${tc_htab}" \
            "${ff_profile}/cookies.sqlite" \
            " \
                select \
                    host as domain, \
                    case substr(host,1,1)='.' when 0 then 'FALSE' else 'TRUE' end as flag, \
                    path, \
                    case isSecure when 0 then 'FALSE' else 'TRUE' end as secure, \
                    expiry as expiration, \
                    name, \
                    value
                from \
                    moz_cookies \
            " \
        > "${file_cookies}".1

    cat "${file_cookies}".[01] 2>/dev/null \
        | grep -n . \
        | sort -t: -k 2,99 -k 1,1gr \
        | sort -t: -k 2,99 -u \
        | sort -t: -k 1,1g \
        | cut -d: -f2- \
        > "${file_cookies}".9

    diff "${file_cookies}"{,.9} 2>/dev/null

    if [[ $? -ne 0 && -s "${file_cookies}".9 ]]; then
        command cp -vf "${file_cookies}"{.9,}
    fi
    command rm -vf "${file_cookies}".?

}
