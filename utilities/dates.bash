
_monthToNumber_() {
    # DESC:   Convert a month name to a number
    # ARGS:   None
    # OUTS:   Prints the number of the month to stdout
    # USAGE:  _monthToNumber_ "January"

    local mon="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
    case "$mon" in
        january | jan | ja) echo 1 ;;
        february | feb | fe) echo 2 ;;
        march | mar | ma) echo 3 ;;
        april | apr | ap) echo 4 ;;
        may)          echo 5 ;;
        june | jun | ju) echo 6 ;;
        july | jul)   echo 7 ;;
        august | aug | au) echo 8 ;;
        september | sep | se) echo 9 ;;
        october | oct) echo 10 ;;
        november | nov | no) echo 11 ;;
        december | dec | de) echo 12 ;;
        *)
            warning "month_monthToNumber_: Bad monthname: $1"
            return 1
             ;;
    esac
}

_numberToMonth_() {
    # DESC:   Convert a month number to its name
    # ARGS:   None
    # OUTS:   Prints the name of the month to stdout
    # USAGE:  _numberToMonth_ 1

    local mon="$1"
    case "$mon" in
        1 | 01) echo January ;;
        2 | 02) echo February ;;
        3 | 03) echo March ;;
        4 | 04) echo April ;;
        5 | 05) echo May  ;;
        6 | 06) echo June ;;
        7 | 07) echo July ;;
        8 | 08) echo August ;;
        9 | 09) echo September ;;
        10) echo October  ;;
        11) echo November ;;
        12) echo December ;;
        *)
            warning "_numberToMonth_: Bad month number: $1"
            return 1
             ;;
    esac
}

_parseDate_() {
    # DESC:   Takes a string as input and attempts to find a date within it
    #         to parse into component parts (day, month, year)
    # ARGS:   $1 (required) - A string
    # OUTS:   Returns error if no date found
    #         $_parseDate_found      - The date found in the string
    #         $_parseDate_year       - The year
    #         $_parseDate_month      - The number month
    #         $_parseDate_monthName  - The name of the month
    #         $_parseDate_day        - The day
    #         $_parseDate_hour       - The hour (if avail)
    #         $_parseDate_minute     - The minute (if avail)
    # USAGE:  if _parseDate_ "[STRING]"; then ...
    # NOTE:   This function only recognizes dates from the year 2000 to 2029
    # NOTE:   Will recognize dates in the following formats separated by '-_ ./'
    #               * YYYY-MM-DD      * Month DD, YYYY    * DD Month, YYYY
    #               * Month, YYYY     * Month, DD YY      * MM-DD-YYYY
    #               * MMDDYYYY        * YYYYMMDD          * DDMMYYYY
    #               * YYYYMMDDHHMM    * YYYYMMDDHH        * DD-MM-YYYY
    #               * DD MM YY        * MM DD YY
    # TODO:   Impelemt the following date formats
    #               * MMDDYY          * YYMMDD            * mon-DD-YY
    # TODO:  Simplify and reduce the number of regex checks


    [[ $# -eq 0 ]] && {
        error 'Missing required argument to _parseDate_()!'
        return 1
    }

    local date="${1:-$(date +%F)}"
    _parseDate_found="" _parseDate_year=""  _parseDate_month=""  _parseDate_monthName=""
    _parseDate_day=""  _parseDate_hour=""   _parseDate_minute=""

    shopt -s nocasematch #Use case-insensitive regex

    debug "_parseDate_() input ${tan}$date${purple}"

    # YYYY MM DD or YYYY-MM-DD
    pat="(.*[^0-9]|^)((20[0-2][0-9])[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2}))([^0-9].*|$)"
    if [[ ${date} =~ $pat ]]; then
        _parseDate_found="${BASH_REMATCH[2]}"
        _parseDate_year=$((10#${BASH_REMATCH[3]}))
        _parseDate_month=$((10#${BASH_REMATCH[4]}))
        _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
        _parseDate_day=$((10#${BASH_REMATCH[5]}))
        debug "regex match: ${tan}YYYY-MM-DD${purple}"

    # Month DD, YYYY
    elif [[ ${date} =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec)[-\./_ ]+([0-9]{1,2})(nd|rd|th|st)?,?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
        _parseDate_found="${BASH_REMATCH[1]:-}"
        _parseDate_month=$(_monthToNumber_ ${BASH_REMATCH[2]:-})
        _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month:-}")"
        _parseDate_day=$((10#${BASH_REMATCH[3]:-}))
        _parseDate_year=$((10#${BASH_REMATCH[5]:-}))
        debug "regex match: ${tan}Month DD, YYYY${purple}"

    # Month DD, YY
    elif [[ ${date} =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec)[-\./_ ]+([0-9]{1,2})(nd|rd|th|st)?,?[-\./_ ]+([0-9]{2}))([^0-9].*|$) ]]; then
        _parseDate_found="${BASH_REMATCH[1]}"
        _parseDate_month=$(_monthToNumber_ ${BASH_REMATCH[2]})
        _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
        _parseDate_day=$((10#${BASH_REMATCH[3]}))
        _parseDate_year="20$((10#${BASH_REMATCH[5]}))"
        debug "regex match: ${tan}Month DD, YY${purple}"

    #  DD Month YYYY
    elif [[ ${date} =~ (.*[^0-9]|^)(([0-9]{2})[-\./_ ]+(january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec),?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
        _parseDate_found="${BASH_REMATCH[2]}"
        _parseDate_day=$((10#"${BASH_REMATCH[3]}"))
        _parseDate_month="$(_monthToNumber_ "${BASH_REMATCH[4]}")"
        _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
        _parseDate_year=$((10#"${BASH_REMATCH[5]}"))
        debug "regex match: ${tan}DD Month, YYYY${purple}"

    # MM-DD-YYYY  or  DD-MM-YYYY
    elif [[ ${date} =~ (.*[^0-9]|^)(([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then

        if [[ $((10#${BASH_REMATCH[3]})) -lt 13 &&
            $((10#${BASH_REMATCH[4]})) -gt 12 &&
            $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
            ; then
            _parseDate_found="${BASH_REMATCH[2]}"
            _parseDate_year=$((10#${BASH_REMATCH[5]}))
            _parseDate_month=$((10#${BASH_REMATCH[3]}))
            _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
            _parseDate_day=$((10#${BASH_REMATCH[4]}))
            debug "regex match: ${tan}MM-DD-YYYY${purple}"
        elif [[ $((10#${BASH_REMATCH[3]})) -gt 12 &&
              $((10#${BASH_REMATCH[3]})) -lt 32 &&
              $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            _parseDate_found="${BASH_REMATCH[2]}"
            _parseDate_year=$((10#${BASH_REMATCH[5]}))
            _parseDate_month=$((10#${BASH_REMATCH[4]}))
            _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
            _parseDate_day=$((10#${BASH_REMATCH[3]}))
            debug "regex match: ${tan}DD-MM-YYYY${purple}"
        elif [[ $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            _parseDate_found="${BASH_REMATCH[2]}"
            _parseDate_year=$((10#${BASH_REMATCH[5]}))
            _parseDate_month=$((10#${BASH_REMATCH[3]}))
            _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
            _parseDate_day=$((10#${BASH_REMATCH[4]}))
            debug "regex match: ${tan}MM-DD-YYYY${purple}"
        else
            shopt -u nocasematch
            return 1
        fi

    elif [[ ${date} =~ (.*[^0-9]|^)(([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+([0-9]{2}))([^0-9].*|$) ]]; then

        if [[ $((10#${BASH_REMATCH[3]})) -lt 13 &&
            $((10#${BASH_REMATCH[4]})) -gt 12 &&
            $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
            ; then
            _parseDate_found="${BASH_REMATCH[2]}"
            _parseDate_year="20$((10#${BASH_REMATCH[5]}))"
            _parseDate_month=$((10#${BASH_REMATCH[3]}))
            _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
            _parseDate_day=$((10#${BASH_REMATCH[4]}))
            debug "regex match: ${tan}MM-DD-YYYY${purple}"
        elif [[ $((10#${BASH_REMATCH[3]})) -gt 12 &&
              $((10#${BASH_REMATCH[3]})) -lt 32 &&
              $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            _parseDate_found="${BASH_REMATCH[2]}"
            _parseDate_year="20$((10#${BASH_REMATCH[5]}))"
            _parseDate_month=$((10#${BASH_REMATCH[4]}))
            _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
            _parseDate_day=$((10#${BASH_REMATCH[3]}))
            debug "regex match: ${tan}DD-MM-YYYY${purple}"
        elif [[ $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            _parseDate_found="${BASH_REMATCH[2]}"
            _parseDate_year="20$((10#${BASH_REMATCH[5]}))"
            _parseDate_month=$((10#${BASH_REMATCH[3]}))
            _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
            _parseDate_day=$((10#${BASH_REMATCH[4]}))
            debug "regex match: ${tan}MM-DD-YYYY${purple}"
        else
            shopt -u nocasematch
            return 1
        fi

    # Month, YYYY
    elif [[ ${date} =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec),?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
        _parseDate_found="${BASH_REMATCH[1]}"
        _parseDate_day="1"
        _parseDate_month="$(_monthToNumber_ "${BASH_REMATCH[2]}")"
        _parseDate_monthName="$(_numberToMonth_ $_parseDate_month)"
        _parseDate_year="$((10#${BASH_REMATCH[3]}))"
        debug "regex match: ${tan}Month, YYYY${purple}"

    # YYYYMMDDHHMM
    elif [[ ${date} =~ (.*[^0-9]|^)((20[0-2][0-9])([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then
        _parseDate_found="${BASH_REMATCH[2]}"
        _parseDate_day="$((10#${BASH_REMATCH[5]}))"
        _parseDate_month="$((10#${BASH_REMATCH[4]}))"
        _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
        _parseDate_year="$((10#${BASH_REMATCH[3]}))"
        _parseDate_hour="$((10#${BASH_REMATCH[6]}))"
        _parseDate_minute="$((10#${BASH_REMATCH[7]}))"
        debug "regex match: ${tan}YYYYMMDDHHMM${purple}"

    # YYYYMMDDHH            1      2        3         4         5         6
    elif [[ ${date} =~ (.*[^0-9]|^)((20[0-2][0-9])([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then
        _parseDate_found="${BASH_REMATCH[2]}"
        _parseDate_day="$((10#${BASH_REMATCH[5]}))"
        _parseDate_month="$((10#${BASH_REMATCH[4]}))"
        _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
        _parseDate_year="$((10#${BASH_REMATCH[3]}))"
        _parseDate_hour="${BASH_REMATCH[6]}"
        _parseDate_minute="00"
        debug "regex match: ${tan}YYYYMMDDHHMM${purple}"

    # MMDDYYYY or YYYYMMDD or DDMMYYYY
    #                        1     2    3         4         5         6
    elif [[ ${date} =~ (.*[^0-9]|^)(([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then

        # MMDDYYYY
        if [[ $((10#${BASH_REMATCH[5]})) -eq 20 &&
              $((10#${BASH_REMATCH[3]})) -lt 13 &&
              $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
            ; then
              _parseDate_found="${BASH_REMATCH[2]}"
              _parseDate_day="$((10#${BASH_REMATCH[4]}))"
              _parseDate_month="$((10#${BASH_REMATCH[3]}))"
              _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
              _parseDate_year="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
              debug "regex match: ${tan}MMDDYYYY${purple}"
        # DDMMYYYY
        elif [[ $((10#${BASH_REMATCH[5]})) -eq 20 &&
              $((10#${BASH_REMATCH[3]})) -gt 12 &&
              $((10#${BASH_REMATCH[3]})) -lt 32 &&
              $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
              _parseDate_found="${BASH_REMATCH[2]}"
              _parseDate_day="$((10#${BASH_REMATCH[3]}))"
              _parseDate_month="$((10#${BASH_REMATCH[4]}))"
              _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
              _parseDate_year="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
              debug "regex match: ${tan}DDMMYYYY${purple}"
        # YYYYMMDD
        elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
              $((10#${BASH_REMATCH[6]})) -gt 12 &&
              $((10#${BASH_REMATCH[6]})) -lt 32 &&
              $((10#${BASH_REMATCH[5]})) -lt 13 ]] \
            ; then
              _parseDate_found="${BASH_REMATCH[2]}"
              _parseDate_day="$((10#${BASH_REMATCH[6]}))"
              _parseDate_month="$((10#${BASH_REMATCH[5]}))"
              _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
              _parseDate_year="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
              debug "regex match: ${tan}YYYYMMDD${purple}"
        # YYYYDDMM
        elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
              $((10#${BASH_REMATCH[5]})) -gt 12 &&
              $((10#${BASH_REMATCH[5]})) -lt 32 &&
              $((10#${BASH_REMATCH[6]})) -lt 13 ]] \
            ; then
              _parseDate_found="${BASH_REMATCH[2]}"
              _parseDate_day="$((10#${BASH_REMATCH[5]}))"
              _parseDate_month="$((10#${BASH_REMATCH[6]}))"
              _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
              _parseDate_year="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
              debug "regex match: ${tan}YYYYMMDD${purple}"
        # Assume YYYMMDD
        elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
              $((10#${BASH_REMATCH[6]})) -lt 32 &&
              $((10#${BASH_REMATCH[5]})) -lt 13 ]] \
            ; then
              _parseDate_found="${BASH_REMATCH[2]}"
              _parseDate_day="$((10#${BASH_REMATCH[6]}))"
              _parseDate_month="$((10#${BASH_REMATCH[5]}))"
              _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
              _parseDate_year="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
              debug "regex match: ${tan}YYYYMMDD${purple}"
        else
            shopt -u nocasematch
            return 1
        fi

    # # MMDD or DDYY
    # elif [[ "$date" =~ .*(([0-9]{2})([0-9]{2})).* ]]; then
    #     debug "regex match: ${tan}MMDD or DDMM${purple}"
    #     _parseDate_found="${BASH_REMATCH[1]}"

    #    # Figure out if days are months or vice versa
    #     if [[ $(( 10#${BASH_REMATCH[2]} )) -gt 12 \
    #        && $(( 10#${BASH_REMATCH[2]} )) -lt 32 \
    #        && $(( 10#${BASH_REMATCH[3]} )) -lt 13 \
    #       ]]; then
    #             _parseDate_day="$(( 10#${BASH_REMATCH[2]} ))"
    #             _parseDate_month="$(( 10#${BASH_REMATCH[3]} ))"
    #             _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
    #             _parseDate_year="$(date +%Y )"
    #     elif [[ $(( 10#${BASH_REMATCH[2]} )) -lt 13 \
    #          && $(( 10#${BASH_REMATCH[3]} )) -lt 32 \
    #          ]]; then
    #             _parseDate_day="$(( 10#${BASH_REMATCH[3]} ))"
    #             _parseDate_month="$(( 10#${BASH_REMATCH[2]} ))"
    #             _parseDate_monthName="$(_numberToMonth_ "${_parseDate_month}")"
    #             _parseDate_year="$(date +%Y )"
    #     else
    #       shopt -u nocasematch
    #       return 1
    #     fi
    else
        shopt -u nocasematch
        return 1

    fi

    [[ -z ${_parseDate_year:-} ]]                         && {
                                                               shopt -u nocasematch
                                                                                      return 1
    }
    ((_parseDate_month >= 1 && _parseDate_month <= 12))   || {
                                                               shopt -u nocasematch
                                                                                      return 1
    }
    ((_parseDate_day >= 1 && _parseDate_day <= 31))       || {
                                                               shopt -u nocasematch
                                                                                      return 1
    }

    debug "${tan}\$_parseDate_found:     ${_parseDate_found}${purple}"
    debug "${tan}\$_parseDate_year:      ${_parseDate_year}${purple}"
    debug "${tan}\$_parseDate_month:     ${_parseDate_month}${purple}"
    debug "${tan}\$_parseDate_monthName: ${_parseDate_monthName}${purple}"
    debug "${tan}\$_parseDate_day:       ${_parseDate_day}${purple}"
    [[ -z ${_parseDate_hour:-} ]]  || debug "${tan}\$_parseDate_hour:     ${_parseDate_hour}${purple}"
    [[ -z ${_parseDate_minute:-} ]] || debug "${tan}\$_parseDate_minute:   ${_parseDate_minute}${purple}"

    shopt -u nocasematch

    # Output results for BATS tests
    if [ "${automated_test_in_progress:-}" ]; then
        echo "_parseDate_found: ${_parseDate_found}"
        echo "_parseDate_year: ${_parseDate_year}"
        echo "_parseDate_month: ${_parseDate_month}"
        echo "_parseDate_monthName: ${_parseDate_monthName}"
        echo "_parseDate_day: ${_parseDate_day}"
        echo "_parseDate_hour: ${_parseDate_hour}"
        echo "_parseDate_minute: ${_parseDate_minute}"
    fi
}

_formatDate_() {
    # DESC:   Reformats dates into user specified formats
    # ARGS:   $1 (Required) - Date to be formatted
    #         $2 (Optional) - Format in any format accepted by bash's date command. Examples listed below.
    #                           %F - YYYY-MM-DD
    #                           %D - MM/DD/YY
    #                           %a - Name of weekday in short (like Sun, Mon, Tue, Wed, Thu, Fri, Sat)
    #                           %A - Name of weekday in full (like Sunday, Monday, Tuesday)
    #                           '+%m %d, %Y'  - 12 27, 2019
    # OUTS:   Echo result to STDOUT
    # USAGE:  _formatDate_ "Jan 10, 2019" "%D"
    # NOTE:   Defaults to YYYY-MM-DD or $(date +%F)

    [[ $# -eq 0 ]] && {
        error 'Missing required argument to _formatDate_()'
        return 1
    }

    local d="${1}"
    local format="${2:-%F}"
    format="${format//+/}"

    if command -v gdate >/dev/null 2>&1; then
        gdate -d "${d}" "+${format}"
    else
        date -d "${d}" "+${format}"
    fi
}
