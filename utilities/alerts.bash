# Functions for providing alerts to the user and logging them
# shellcheck disable=SC2034,SC2154

_setColors_() {
    # DESC:
    #         Sets colors use for alerts.
    # ARGS:
    #         None
    # OUTS:
    #         None
    # USAGE:
    #         printf "%s\n" "${blue}Some text${reset}"

    if tput setaf 1 >/dev/null 2>&1; then
        bold=$(tput bold)
        underline=$(tput smul)
        reverse=$(tput rev)
        reset=$(tput sgr0)

        if [[ $(tput colors) -ge 256 ]] >/dev/null 2>&1; then
            white=$(tput setaf 231)
            blue=$(tput setaf 38)
            yellow=$(tput setaf 11)
            green=$(tput setaf 82)
            red=$(tput setaf 9)
            purple=$(tput setaf 171)
            gray=$(tput setaf 250)
        else
            white=$(tput setaf 7)
            blue=$(tput setaf 38)
            yellow=$(tput setaf 3)
            green=$(tput setaf 2)
            red=$(tput setaf 9)
            purple=$(tput setaf 13)
            gray=$(tput setaf 7)
        fi
    else
        bold="\033[4;37m"
        reset="\033[0m"
        underline="\033[4;37m"
        # shellcheck disable=SC2034
        reverse=""
        white="\033[0;37m"
        blue="\033[0;34m"
        yellow="\033[0;33m"
        green="\033[1;32m"
        red="\033[0;31m"
        purple="\033[0;35m"
        gray="\033[0;37m"
    fi
}

_alert_() {
    # DESC:
    #         Controls all printing of messages to log files and stdout.
    # ARGS:
    #         $1 (required) - The type of alert to print
    #                         (success, header, notice, dryrun, debug, warning, error,
    #                         fatal, info, input)
    #         $2 (required) - The message to be printed to stdout and/or a log file
    #         $3 (optional) - Pass '${LINENO}' to print the line number where the _alert_ was triggered
    # OUTS:
    #         stdout: The message is printed to stdout
    #         log file: The message is printed to a log file
    # USAGE:
    #         [_alertType] "[MESSAGE]" "${LINENO}"
    # NOTES:
    #         - The colors of each alert type are set in this function
    #         - For specified alert types, the funcstac will be printed

    local _color
    local _alertType="${1}"
    local _message="${2}"
    local _line="${3:-}" # Optional line number

    [[ $# -lt 2 ]] && fatal 'Missing required argument to _alert_'

    if [[ -n ${_line} && ${_alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        _message="${_message} ${gray}(line: ${_line}) $(_printFuncStack_)"
    elif [[ -n ${_line} && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        _message="${_message} ${gray}(line: ${_line})"
    elif [[ -z ${_line} && ${_alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        _message="${_message} ${gray}$(_printFuncStack_)"
    fi

    if [[ ${_alertType} =~ ^(error|fatal) ]]; then
        _color="${bold}${red}"
    elif [ "${_alertType}" == "info" ]; then
        _color="${gray}"
    elif [ "${_alertType}" == "warning" ]; then
        _color="${red}"
    elif [ "${_alertType}" == "success" ]; then
        _color="${green}"
    elif [ "${_alertType}" == "debug" ]; then
        _color="${purple}"
    elif [ "${_alertType}" == "header" ]; then
        _color="${bold}${white}${underline}"
    elif [ "${_alertType}" == "notice" ]; then
        _color="${bold}"
    elif [ "${_alertType}" == "input" ]; then
        _color="${bold}${underline}"
    elif [ "${_alertType}" = "dryrun" ]; then
        _color="${blue}"
    else
        _color=""
    fi

    _writeToScreen_() {
        [[ ${QUIET} == true ]] && return 0 # Print to console when script is not 'quiet'
        [[ ${VERBOSE} == false && ${_alertType} =~ ^(debug|verbose) ]] && return 0

        if ! [[ -t 1 || -z ${TERM:-} ]]; then # Don't use colors on non-recognized terminals
            _color=""
            reset=""
        fi

        if [[ ${_alertType} == header ]]; then
            printf "${_color}%s${reset}\n" "${_message}"
        else
            printf "${_color}[%7s] %s${reset}\n" "${_alertType}" "${_message}"
        fi
    }
    _writeToScreen_

    _writeToLog_() {
        [[ ${_alertType} == "input" ]] && return 0
        [[ ${LOGLEVEL} =~ (off|OFF|Off) ]] && return 0
        if [ -z "${LOGFILE:-}" ]; then
            LOGFILE="$(pwd)/$(basename "$0").log"
        fi
        [ ! -d "$(dirname "${LOGFILE}")" ] && mkdir -p "$(dirname "${LOGFILE}")"
        [[ ! -f ${LOGFILE} ]] && touch "${LOGFILE}"

        # Don't use colors in logs
        local _cleanmessage
        _cleanmessage="$(printf "%s" "${_message}" | sed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
        # Print message to log file
        printf "%s [%7s] %s %s\n" "$(date +"%b %d %R:%S")" "${_alertType}" "[$(/bin/hostname)]" "${_cleanmessage}" >>"${LOGFILE}"
    }

    # Write specified log level data to logfile
    case "${LOGLEVEL:-ERROR}" in
        ALL | all | All)
            _writeToLog_
            ;;
        DEBUG | debug | Debug)
            _writeToLog_
            ;;
        INFO | info | Info)
            if [[ ${_alertType} =~ ^(error|fatal|warning|info|notice|success) ]]; then
                _writeToLog_
            fi
            ;;
        NOTICE | notice | Notice)
            if [[ ${_alertType} =~ ^(error|fatal|warning|notice|success) ]]; then
                _writeToLog_
            fi
            ;;
        WARN | warn | Warn)
            if [[ ${_alertType} =~ ^(error|fatal|warning) ]]; then
                _writeToLog_
            fi
            ;;
        ERROR | error | Error)
            if [[ ${_alertType} =~ ^(error|fatal) ]]; then
                _writeToLog_
            fi
            ;;
        FATAL | fatal | Fatal)
            if [[ ${_alertType} =~ ^fatal ]]; then
                _writeToLog_
            fi
            ;;
        OFF | off)
            return 0
            ;;
        *)
            if [[ ${_alertType} =~ ^(error|fatal) ]]; then
                _writeToLog_
            fi
            ;;
    esac

} # /_alert_

error() { _alert_ error "${1}" "${2:-}"; }
warning() { _alert_ warning "${1}" "${2:-}"; }
notice() { _alert_ notice "${1}" "${2:-}"; }
info() { _alert_ info "${1}" "${2:-}"; }
success() { _alert_ success "${1}" "${2:-}"; }
dryrun() { _alert_ dryrun "${1}" "${2:-}"; }
input() { _alert_ input "${1}" "${2:-}"; }
header() { _alert_ header "${1}" "${2:-}"; }
debug() { _alert_ debug "${1}" "${2:-}"; }
fatal() {
    _alert_ fatal "${1}" "${2:-}"
    return 1
}

_printFuncStack_() {
    # DESC:
    #         Prints the function stack in use. Used for debugging, and error reporting.
    # ARGS:
    #         None
    # OUTS:
    #         stdout: Prints [function]:[file]:[line]
    # NOTE:
    #         Does not print functions from the alert class
    local _i
    declare -a _funcStackResponse=()
    for ((_i = 1; _i < ${#BASH_SOURCE[@]}; _i++)); do
        case "${FUNCNAME[${_i}]}" in
            _alert_ | _trapCleanup_ | fatal | error | warning | notice | info | debug | dryrun | header | success)
                continue
                ;;
            *)
                _funcStackResponse+=("${FUNCNAME[${_i}]}:$(basename "${BASH_SOURCE[${_i}]}"):${BASH_LINENO[_i - 1]}")
                ;;
        esac

    done
    printf "( "
    printf %s "${_funcStackResponse[0]}"
    printf ' < %s' "${_funcStackResponse[@]:1}"
    printf ' )\n'
}

_centerOutput_() {
    # DESC:
    #					Prints text centered in the terminal window with an optional fill character
    # ARGS:
    #         $1 (required): Text to center
    #         $2 (optional): Fill character
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout:
    # USAGE:
    #					_centerOutput_ "Text to print in the center" "-"
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"
    local _input="${1}"
    local _symbol="${2:- }"
    local _filler
    local _out
    local _no_ansi_out
    local i

    _no_ansi_out=$(_stripANSI_ "${_input}")
    declare -i _str_len=${#_no_ansi_out}
    declare -i _filler_len="$(((COLUMNS - _str_len) / 2))"

    [[ -n ${_symbol} ]] && _symbol="${_symbol:0:1}"
    for ((i = 0; i < _filler_len; i++)); do
        _filler+="${_symbol}"
    done

    _out="${_filler}${_input}${_filler}"
    [[ $(((COLUMNS - _str_len) % 2)) -ne 0 ]] && _out+="${_symbol}"
    printf "%s\n" "${_out}"
}

_clearLine_() (
    # DESC:
    #					Clears output in the terminal on the specified line number.
    # ARGS:
    #					$1 (Optional): Line number to clear. (Defaults to 1)
    # OUTS:
    #							 0:  Success
    #							 1:  Failure
    # USAGE:
    #					_clearLine_ "2"

    ! declare -f _isTerminal_ &>/dev/null && fatal "${FUNCNAME[0]} needs function _isTerminal_"

    local _num="${1:-1}"
    local i

    if _isTerminal_; then
        for ((i = 0; i < _num; i++)); do
            printf "\033[A\033[2K"
        done
    fi
)

_columns_() {
    # DESC:
    #         Prints a two column output with fixed widths and wrapping text from a key/value pair.
    #         Optionally pass a number of 2 space tabs to indent the output.
    # ARGS:
    #         $1 (required): Key name (Left column text)
    #         $2 (required): Long value (Right column text. Wraps around if too long)
    #         $3 (optional): Number of 2 character tabs to indent the command (default 1)
    #         $4 (optional): Total character width of the left column (default 35)
    # OPTS:
    #         -b    Bold the left column
    #         -u    Underline the left column
    #         -r    Reverse background and foreground colors
    # OUTS:
    #         stdout: Prints the output in columns
    # NOTE:
    #         Long text or ANSI colors in the first column may create display issues
    # USAGE:
    #         _columns_ "Key" "Long value text" [tab level]

    [[ $# -lt 2 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local opt
    local OPTIND=1
    local _style=""
    while getopts ":bBuUrR" opt; do
        case ${opt} in
            b | B) _style="${_style}${bold}" ;;
            u | U) _style="${_style}${underline}" ;;
            r | R) _style="${_style}${reverse}" ;;
            *) fatal "Unrecognized option '${1}' passed to ${FUNCNAME[0]}. Exiting." ;;
        esac
    done
    shift $((OPTIND - 1))

    local _key="${1}"
    local _value="${2}"
    local _tabLevel="${3:-0}"
    local _leftColumnWidth="${4:-35}"
    local _tabSize=2
    local _line
    local _rightIndent
    local _leftIndent

    _leftIndent="$((_tabLevel * _tabSize))"

    local _leftColumnWidth="$((_leftColumnWidth - _leftIndent))"

    if [ "$(tput cols)" -gt 180 ]; then
        _rightIndent=110
    elif [ "$(tput cols)" -gt 160 ]; then
        _rightIndent=90
    elif [ "$(tput cols)" -gt 130 ]; then
        _rightIndent=60
    elif [ "$(tput cols)" -gt 120 ]; then
        _rightIndent=50
    elif [ "$(tput cols)" -gt 110 ]; then
        _rightIndent=40
    elif [ "$(tput cols)" -gt 100 ]; then
        _rightIndent=30
    elif [ "$(tput cols)" -gt 90 ]; then
        _rightIndent=20
    elif [ "$(tput cols)" -gt 80 ]; then
        _rightIndent=10
    else
        _rightIndent=0
    fi

    local _rightWrapLength=$(($(tput cols) - _leftColumnWidth - _leftIndent - _rightIndent))

    local _first_line=0
    while read -r _line; do
        if [[ ${_first_line} -eq 0 ]]; then
            _first_line=1
        else
            _key=" "
        fi
        printf "%-${_leftIndent}s${_style}%-${_leftColumnWidth}b${reset} %b\n" "" "${_key}${reset}" "${_line}"
    done <<<"$(fold -w${_rightWrapLength} -s <<<"${_value}")"
}
