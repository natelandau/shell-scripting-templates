#! /dev/null/bash

function curl_as_ff ()
{

    local -- tc_htab
    local -- file_cookies head_useragent

    printf -v tc_htab '\t'

    file_cookies=~/.curl/cookies_ff
    head_useragent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:47.0) Gecko/20100101 Firefox/47.0'

    curl -A "${head_useragent}" -b "${file_cookies}" -c "${file_cookies}" "$@"

}
