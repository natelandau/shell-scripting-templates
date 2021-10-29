# Functions to help work with dates and time

_convertToUnixTimestamp_() {
    # DESC:
    #					Convert date string to unix timestamp
    # ARGS:
    #					$1 (Required) - Date to be converted
    # OUTS:
    #					0 If successful
    #					1 If failed to convert
    #         stdout: timestamp for specified date/time
    # USAGE:
    #					printf "%s\n" "$(_convertToUnixTimestamp_ "Jan 10, 2019")"
    # NOTES:
    #
    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _date
    _date=$(date -d "${1}" +"%s") || return 1
    printf "%s\n" "${_date}"

}

_countdown_() {
    # DESC:
    #         Sleep for a specified amount of time
    # ARGS:
    #         $1 (Optional) - Total seconds to sleep for(Default is 10)
    #         $2 (Optional) - Increment to count down
    #         $3 (Optional) - Message to print at each increment (default is ...)
    # OUTS:
    #         stdout: Prints the message at each increment
    # USAGE:
    #         _countdown_ 10 1 "Waiting for cache to invalidate"

    local i ii t
    local _n=${1:-10}
    local _sleepTime=${2:-1}
    local _message="${3:-...}"
    ((t = _n + 1))

    for ((i = 1; i <= _n; i++)); do
        ((ii = t - i))
        if declare -f "info" &>/dev/null 2>&1; then
            info "${_message} ${ii}"
        else
            echo "${_message} ${ii}"
        fi
        sleep "${_sleepTime}"
    done
}

_dateUnixTimestamp_() {
    # DESC:
    #         Get the current time in unix timestamp
    # ARGS:
    #         None
    # OUTS:
    #         stdout: Prints result ~ 1591554426
    #         0 If successful
    #         1 If failed to get timestamp
    # USAGE:
    #         _dateUnixTimestamp_

    local _now
    _now="$(date --universal +%s)" || return 1
    printf "%s\n" "${_now}"
}

_formatDate_() {
    # DESC:
    #         Reformats dates into user specified formats
    # ARGS:
    #         $1 (Required) - Date to be formatted
    #         $2 (Optional) - Format in any format accepted by bash's date command.
    #                         Examples:
    #                           %F - YYYY-MM-DD
    #                           %D - MM/DD/YY
    #                           %a - Name of weekday in short (like Sun, Mon, Tue, Wed, Thu, Fri, Sat)
    #                           %A - Name of weekday in full (like Sunday, Monday, Tuesday)
    #                           '+%m %d, %Y'  - 12 27, 2019
    # OUTS:
    #         stdout: Prints result
    # USAGE:
    #         _formatDate_ "Jan 10, 2019" "%D"
    # NOTE:
    #         Defaults to YYYY-MM-DD or $(date +%F)

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _d="${1}"
    local _format="${2:-%F}"
    _format="${_format//+/}"

    date -d "${_d}" "+${_format}"
}

_fromSeconds_() {
    # DESC:
    #         Convert seconds to HH:MM:SS
    # ARGS:
    #         $1 (Required) - Time in seconds
    # OUTS:
    #         stdout: HH:MM:SS
    # USAGE:
    #         _fromSeconds_ "SECONDS"
    # EXAMPLE:
    #         To compute the time it takes a script to run:
    #             STARTTIME=$(date +"%s")
    #             ENDTIME=$(date +"%s")
    #             TOTALTIME=$(($ENDTIME-$STARTTIME)) # human readable time
    #             _fromSeconds_ "$TOTALTIME"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _h
    local _m
    local _s

    ((_h = ${1} / 3600))
    ((_m = (${1} % 3600) / 60))
    ((_s = ${1} % 60))
    printf "%02d:%02d:%02d\n" "${_h}" "${_m}" "${_s}"
}

_monthToNumber_() {
    # DESC:
    #         Convert a month name to a number
    # ARGS:
    #         $1 (Required) - Month name
    # OUTS:
    #         stdout: Prints the number of the month (1-12)
    # USAGE:
    #         _monthToNumber_ "January"

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _mon
    _mon="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

    case "${_mon}" in
        january | jan | ja) echo 1 ;;
        february | feb | fe) echo 2 ;;
        march | mar | ma) echo 3 ;;
        april | apr | ap) echo 4 ;;
        may) echo 5 ;;
        june | jun | ju) echo 6 ;;
        july | jul) echo 7 ;;
        august | aug | au) echo 8 ;;
        september | sep | se) echo 9 ;;
        october | oct | oc) echo 10 ;;
        november | nov | no) echo 11 ;;
        december | dec | de) echo 12 ;;
        *)
            warning "_monthToNumber_: Bad month name: ${_mon}"
            return 1
            ;;
    esac
}

_numberToMonth_() {
    # DESC:
    #         Convert a month number to its name
    # ARGS:
    #         $1 (Required) - Month number (1-12)
    # OUTS:
    #         stdout: Prints the name of the month
    # USAGE:
    #         _numberToMonth_ 11

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _mon="$1"
    case "${_mon}" in
        1 | 01) echo January ;;
        2 | 02) echo February ;;
        3 | 03) echo March ;;
        4 | 04) echo April ;;
        5 | 05) echo May ;;
        6 | 06) echo June ;;
        7 | 07) echo July ;;
        8 | 08) echo August ;;
        9 | 09) echo September ;;
        10) echo October ;;
        11) echo November ;;
        12) echo December ;;
        *)
            warning "_numberToMonth_: Bad month number: ${_mon}"
            return 1
            ;;
    esac
}

_parseDate_() {
    # DESC:
    #         Takes a string as input and attempts to find a date within it to parse
    #         into component parts (day, month, year)
    # ARGS:
    #         $1 (required) - A string
    # OUTS:
    #         0 if date is found
    #         1 if date is NOT found
    #         If a date was found, the following variables are set:
    #             $PARSE_DATE_FOUND      - The date found in the string
    #             $PARSE_DATE_YEAR       - The year
    #             $PARSE_DATE_MONTH      - The number month
    #             $PARSE_DATE_MONTH_NAME - The name of the month
    #             $PARSE_DATE_DAY        - The day
    #             $PARSE_DATE_HOUR       - The hour (if avail)
    #             $PARSE_DATE_MINUTE     - The minute (if avail)
    # USAGE:
    #             if _parseDate_ "[STRING]"; then ...
    # NOTE:
    #         - This function only recognizes dates from the year 2000 to 202
    #         - Will recognize dates in the following formats separated by '-_ ./'
    #               * YYYY-MM-DD      * Month DD, YYYY    * DD Month, YYYY
    #               * Month, YYYY     * Month, DD YY      * MM-DD-YYYY
    #               * MMDDYYYY        * YYYYMMDD          * DDMMYYYY
    #               * YYYYMMDDHHMM    * YYYYMMDDHH        * DD-MM-YYYY
    #               * DD MM YY        * MM DD YY
    # TODO:   Impelemt the following date formats
    #               * MMDDYY          * YYMMDD            * mon-DD-YY
    # TODO:  Simplify and reduce the number of regex checks

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _stringToTest="${1}"
    local _pat

    PARSE_DATE_FOUND="" PARSE_DATE_YEAR="" PARSE_DATE_MONTH="" PARSE_DATE_MONTH_NAME=""
    PARSE_DATE_DAY="" PARSE_DATE_HOUR="" PARSE_DATE_MINUTE=""

    #shellcheck disable=SC2064
    trap '$(shopt -p nocasematch)' RETURN # reset nocasematch when function exits
    shopt -s nocasematch                  # Use case-insensitive regex

    debug "_parseDate_() input: ${_stringToTest}"

    # YYYY MM DD or YYYY-MM-DD
    _pat="(.*[^0-9]|^)((20[0-2][0-9])[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2}))([^0-9].*|$)"
    if [[ ${_stringToTest} =~ ${_pat} ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
        PARSE_DATE_YEAR=$((10#${BASH_REMATCH[3]}))
        PARSE_DATE_MONTH=$((10#${BASH_REMATCH[4]}))
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
        PARSE_DATE_DAY=$((10#${BASH_REMATCH[5]}))
        debug "regex match: YYYY-MM-DD "

    # Month DD, YYYY
    elif [[ ${_stringToTest} =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec)[-\./_ ]+([0-9]{1,2})(nd|rd|th|st)?,?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[1]:-}"
        PARSE_DATE_MONTH=$(_monthToNumber_ "${BASH_REMATCH[2]:-}")
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH:-}")"
        PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]:-}))
        PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]:-}))
        debug "regex match: Month DD, YYYY"

    # Month DD, YY
    elif [[ ${_stringToTest} =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec)[-\./_ ]+([0-9]{1,2})(nd|rd|th|st)?,?[-\./_ ]+([0-9]{2}))([^0-9].*|$) ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[1]}"
        PARSE_DATE_MONTH=$(_monthToNumber_ "${BASH_REMATCH[2]}")
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
        PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]}))
        PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
        debug "regex match: Month DD, YY"

    #  DD Month YYYY
    elif [[ ${_stringToTest} =~ (.*[^0-9]|^)(([0-9]{2})[-\./_ ]+(january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec),?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
        PARSE_DATE_DAY=$((10#"${BASH_REMATCH[3]}"))
        PARSE_DATE_MONTH="$(_monthToNumber_ "${BASH_REMATCH[4]}")"
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
        PARSE_DATE_YEAR=$((10#"${BASH_REMATCH[5]}"))
        debug "regex match: DD Month, YYYY"

    # MM-DD-YYYY  or  DD-MM-YYYY
    elif [[ ${_stringToTest} =~ (.*[^0-9]|^)(([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then

        if [[ $((10#${BASH_REMATCH[3]})) -lt 13 &&
            $((10#${BASH_REMATCH[4]})) -gt 12 &&
            $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]}))
            PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
            debug "regex match: MM-DD-YYYY"
        elif [[ $((10#${BASH_REMATCH[3]})) -gt 12 &&
            $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]}))
            PARSE_DATE_MONTH=$((10#${BASH_REMATCH[4]}))
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]}))
            debug "regex match: DD-MM-YYYY"
        elif [[ $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_YEAR=$((10#${BASH_REMATCH[5]}))
            PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
            debug "regex match: MM-DD-YYYY"
        else
            shopt -u nocasematch
            return 1
        fi

    elif [[ ${_stringToTest} =~ (.*[^0-9]|^)(([0-9]{1,2})[-\.\/_ ]+([0-9]{1,2})[-\.\/_ ]+([0-9]{2}))([^0-9].*|$) ]]; then

        if [[ $((10#${BASH_REMATCH[3]})) -lt 13 &&
            $((10#${BASH_REMATCH[4]})) -gt 12 &&
            $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
            PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
            debug "regex match: MM-DD-YYYY"
        elif [[ $((10#${BASH_REMATCH[3]})) -gt 12 &&
            $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
            PARSE_DATE_MONTH=$((10#${BASH_REMATCH[4]}))
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_DAY=$((10#${BASH_REMATCH[3]}))
            debug "regex match: DD-MM-YYYY"
        elif [[ $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_YEAR="20$((10#${BASH_REMATCH[5]}))"
            PARSE_DATE_MONTH=$((10#${BASH_REMATCH[3]}))
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_DAY=$((10#${BASH_REMATCH[4]}))
            debug "regex match: MM-DD-YYYY"
        else
            shopt -u nocasematch
            return 1
        fi

    # Month, YYYY
    elif [[ ${_stringToTest} =~ ((january|jan|ja|february|feb|fe|march|mar|ma|april|apr|ap|may|june|jun|july|jul|ju|august|aug|september|sep|october|oct|november|nov|december|dec),?[-\./_ ]+(20[0-2][0-9]))([^0-9].*|$) ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[1]}"
        PARSE_DATE_DAY="1"
        PARSE_DATE_MONTH="$(_monthToNumber_ "${BASH_REMATCH[2]}")"
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
        PARSE_DATE_YEAR="$((10#${BASH_REMATCH[3]}))"
        debug "regex match: Month, YYYY"

    # YYYYMMDDHHMM
    elif [[ ${_stringToTest} =~ (.*[^0-9]|^)((20[0-2][0-9])([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
        PARSE_DATE_DAY="$((10#${BASH_REMATCH[5]}))"
        PARSE_DATE_MONTH="$((10#${BASH_REMATCH[4]}))"
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
        PARSE_DATE_YEAR="$((10#${BASH_REMATCH[3]}))"
        PARSE_DATE_HOUR="$((10#${BASH_REMATCH[6]}))"
        PARSE_DATE_MINUTE="$((10#${BASH_REMATCH[7]}))"
        debug "regex match: YYYYMMDDHHMM"

    # YYYYMMDDHH            1      2        3         4         5         6
    elif [[ ${_stringToTest} =~ (.*[^0-9]|^)((20[0-2][0-9])([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then
        PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
        PARSE_DATE_DAY="$((10#${BASH_REMATCH[5]}))"
        PARSE_DATE_MONTH="$((10#${BASH_REMATCH[4]}))"
        PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
        PARSE_DATE_YEAR="$((10#${BASH_REMATCH[3]}))"
        PARSE_DATE_HOUR="${BASH_REMATCH[6]}"
        PARSE_DATE_MINUTE="00"
        debug "regex match: YYYYMMDDHHMM"

    # MMDDYYYY or YYYYMMDD or DDMMYYYY
    #                        1     2    3         4         5         6
    elif [[ ${_stringToTest} =~ (.*[^0-9]|^)(([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2}))([^0-9].*|$) ]]; then

        # MMDDYYYY
        if [[ $((10#${BASH_REMATCH[5]})) -eq 20 &&
            $((10#${BASH_REMATCH[3]})) -lt 13 &&
            $((10#${BASH_REMATCH[4]})) -lt 32 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_DAY="$((10#${BASH_REMATCH[4]}))"
            PARSE_DATE_MONTH="$((10#${BASH_REMATCH[3]}))"
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_YEAR="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
            debug "regex match: MMDDYYYY"
        # DDMMYYYY
        elif [[ $((10#${BASH_REMATCH[5]})) -eq 20 &&
            $((10#${BASH_REMATCH[3]})) -gt 12 &&
            $((10#${BASH_REMATCH[3]})) -lt 32 &&
            $((10#${BASH_REMATCH[4]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_DAY="$((10#${BASH_REMATCH[3]}))"
            PARSE_DATE_MONTH="$((10#${BASH_REMATCH[4]}))"
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_YEAR="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
            debug "regex match: DDMMYYYY"
        # YYYYMMDD
        elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
            $((10#${BASH_REMATCH[6]})) -gt 12 &&
            $((10#${BASH_REMATCH[6]})) -lt 32 &&
            $((10#${BASH_REMATCH[5]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_DAY="$((10#${BASH_REMATCH[6]}))"
            PARSE_DATE_MONTH="$((10#${BASH_REMATCH[5]}))"
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_YEAR="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
            debug "regex match: YYYYMMDD"
        # YYYYDDMM
        elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
            $((10#${BASH_REMATCH[5]})) -gt 12 &&
            $((10#${BASH_REMATCH[5]})) -lt 32 &&
            $((10#${BASH_REMATCH[6]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_DAY="$((10#${BASH_REMATCH[5]}))"
            PARSE_DATE_MONTH="$((10#${BASH_REMATCH[6]}))"
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_YEAR="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
            debug "regex match: YYYYMMDD"
        # Assume YYYMMDD
        elif [[ $((10#${BASH_REMATCH[3]})) -eq 20 &&
            $((10#${BASH_REMATCH[6]})) -lt 32 &&
            $((10#${BASH_REMATCH[5]})) -lt 13 ]] \
            ; then
            PARSE_DATE_FOUND="${BASH_REMATCH[2]}"
            PARSE_DATE_DAY="$((10#${BASH_REMATCH[6]}))"
            PARSE_DATE_MONTH="$((10#${BASH_REMATCH[5]}))"
            PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
            PARSE_DATE_YEAR="${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
            debug "regex match: YYYYMMDD"
        else
            shopt -u nocasematch
            return 1
        fi

    # # MMDD or DDYY
    # elif [[ "${_stringToTest}" =~ .*(([0-9]{2})([0-9]{2})).* ]]; then
    #     debug "regex match: MMDD or DDMM"
    #     PARSE_DATE_FOUND="${BASH_REMATCH[1]}"

    #    # Figure out if days are months or vice versa
    #     if [[ $(( 10#${BASH_REMATCH[2]} )) -gt 12 \
    #        && $(( 10#${BASH_REMATCH[2]} )) -lt 32 \
    #        && $(( 10#${BASH_REMATCH[3]} )) -lt 13 \
    #       ]]; then
    #             PARSE_DATE_DAY="$(( 10#${BASH_REMATCH[2]} ))"
    #             PARSE_DATE_MONTH="$(( 10#${BASH_REMATCH[3]} ))"
    #             PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
    #             PARSE_DATE_YEAR="$(date +%Y )"
    #     elif [[ $(( 10#${BASH_REMATCH[2]} )) -lt 13 \
    #          && $(( 10#${BASH_REMATCH[3]} )) -lt 32 \
    #          ]]; then
    #             PARSE_DATE_DAY="$(( 10#${BASH_REMATCH[3]} ))"
    #             PARSE_DATE_MONTH="$(( 10#${BASH_REMATCH[2]} ))"
    #             PARSE_DATE_MONTH_NAME="$(_numberToMonth_ "${PARSE_DATE_MONTH}")"
    #             PARSE_DATE_YEAR="$(date +%Y )"
    #     else
    #       shopt -u nocasematch
    #       return 1
    #     fi
    else
        shopt -u nocasematch
        return 1
    fi

    [[ -z ${PARSE_DATE_YEAR:-} ]] && {
        shopt -u nocasematch
        return 1
    }
    ((PARSE_DATE_MONTH >= 1 && PARSE_DATE_MONTH <= 12)) || {
        shopt -u nocasematch
        return 1
    }
    ((PARSE_DATE_DAY >= 1 && PARSE_DATE_DAY <= 31)) || {
        shopt -u nocasematch
        return 1
    }

    debug "\$PARSE_DATE_FOUND:     ${PARSE_DATE_FOUND}"
    debug "\$PARSE_DATE_YEAR:      ${PARSE_DATE_YEAR}"
    debug "\$PARSE_DATE_MONTH:     ${PARSE_DATE_MONTH}"
    debug "\$PARSE_DATE_MONTH_NAME: ${PARSE_DATE_MONTH_NAME}"
    debug "\$PARSE_DATE_DAY:       ${PARSE_DATE_DAY}"
    [[ -z ${PARSE_DATE_HOUR:-} ]] || debug "\$PARSE_DATE_HOUR:     ${PARSE_DATE_HOUR}"
    [[ -z ${PARSE_DATE_MINUTE:-} ]] || debug "\$PARSE_DATE_MINUTE:   ${PARSE_DATE_MINUTE}"

    shopt -u nocasematch
}

_readableUnixTimestamp_() {
    # DESC:
    #					Format unix timestamp to human readable format. If format string is not specified then
    #         default to "yyyy-mm-dd hh:mm:ss"
    # ARGS:
    #					$1 (Required) - Unix timestamp to be formatted
    #         $2 (Optional) - Format string
    # OUTS:
    #					0 If successful
    #         1 If failed to convert
    #         stdout: Human readable format of unix timestamp
    # USAGE:
    #         _readableUnixTimestamp_ "1591554426"
    #         _readableUnixTimestamp_ "1591554426" "%Y-%m-%d"
    # CREDIT:
    #         https://github.com/labbots/bash-utility/blob/master/src/date.sh

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _timestamp="${1}"
    local _format="${2:-"%F %T"}"
    local _out
    _out="$(date -d "@${_timestamp}" +"${_format}")" || return 1
    printf "%s\n" "${_out}"
}

_toSeconds_() {
    # DESC:
    #         Converts HH:MM:SS to seconds
    # ARGS:
    #         $1 (Required) - Time in HH:MM:SS
    # OUTS:
    #         stdout: Print seconds
    # USAGE:
    #         _toSeconds_ "01:00:00"
    # NOTE:
    #         Acceptable Input Formats
    #           24 12 09
    #           12,12,09
    #           12;12;09
    #           12:12:09
    #           12-12-09
    #           12H12M09S
    #           12h12m09s

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _saveIFS
    local _h
    local _m
    local _s

    if [[ $1 =~ [0-9]{1,2}(:|,|-|_|,| |[hHmMsS])[0-9]{1,2}(:|,|-|_|,| |[hHmMsS])[0-9]{1,2} ]]; then
        _saveIFS="${IFS}"
        IFS=":,;-_, HhMmSs" read -r _h _m _s <<<"$1"
        IFS="${_saveIFS}"
    else
        _h="$1"
        _m="$2"
        _s="$3"
    fi

    printf "%s\n" "$((10#${_h} * 3600 + 10#${_m} * 60 + 10#${_s}))"
}
