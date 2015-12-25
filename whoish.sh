#! /dev/null/bash

whoish() {
    #
    # Thanks to xenoxaos for the inspiration! =]
    # https://github.com/xenoxaos
    #
    declare addr curl_cmd json jq_flt urls url
    #
    addr="${1}"
    printf -v jq_flt %s \
        '.nets.net' \
        ' | ' \
            'if ( . | type ) == "object" then' \
                ' . ' \
            'elif ( . | type ) == "array" then' \
                ' .[] ' \
            'else' \
                ' "ERR" ' \
            'end' \
            ' | ' \
                '.ref["$"] , .orgRef["$"]'
    curl_cmd=(
        curl -s
        -H 'Accept: application/json'
        "http://whois.arin.net/rest/nets;q=${addr}?showDetails=true"
    )
    #
    json="$( "${curl_cmd[@]}" )"
    #
    urls=( $( echo "${json}" | jq "${jq_flt}" ) )
    #
    curl -s -H 'Accept: text/plain' "${urls[@]//\"/}" |
        grep -v '^#' |
        uniq
    #
}
