# Functions to aid in debugging bash scripts

_pauseScript_() {
    # DESC:
    #         Pause a script at any point and continue after user input
    # ARGS:
    #         $1 (Optional) - String for customized message

    local _pauseMessage
    _pauseMessage="${1:-Paused. Ready to continue?}"

    if _seekConfirmation_ "${_pauseMessage}"; then
        info "Continuing..."
    else
        notice "Exiting Script"
        _safeExit_
    fi
}

_printAnsi_() {
    # DESC:
    #         Helps debug ansi escape sequence in text by displaying the escape codes
    # ARGS:
    #         $1 (Required) String input with ansi escape sequence.
    # OUTS:
    #         stdout: Ansi escape sequence printed in output as is.
    # USAGE:
    #         _printAnsi_ "$(tput bold)$(tput setaf 9)Some Text"
    # CREDIT:
    #         https://github.com/labbots/bash-utility/blob/master/src/debug.sh

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    #printf "%s\n" "$(tr -dc '[:print:]'<<<$1)"
    printf "%s\n" "${1//$'\e'/\\e}"

}

_printArray_() {
    # DESC:
    #         Prints the content of array as key value pairs for easier debugging. Only prints in verbose mode.
    # ARGS:
    #         $1 (Required) - String variable name of the array
    #         $2 (Optional) - Line number where _printArray_ is called
    # OPTS:
    #         -v - Prints array when VERBOSE is false
    # OUTS:
    #         stdout: Formatted key value of array
    # USAGE:
    #         testArray=("1" "2" "3" "4")
    #         _printArray_ "testArray" ${LINENO}
    # CREDIT:
    #         https://github.com/labbots/bash-utility/blob/master/src/debug.sh

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _printNoVerbose=false
    local opt
    local OPTIND=1
    while getopts ":vV" opt; do
        case ${opt} in
            v | V) _printNoVerbose=true ;;
            *) fatal "Unrecognized option '${1}' passed to ${FUNCNAME[0]}. Exiting." ;;
        esac
    done
    shift $((OPTIND - 1))

    local _arrayName="${1}"
    local _lineNumber="${2:-}"
    declare -n _arr="${1}"

    if [[ ${_printNoVerbose} == "false" ]]; then

        [[ ${VERBOSE:-} != true ]] && return 0

        debug "Contents of \${${_arrayName}[@]}" "${_lineNumber}"

        for _k in "${!_arr[@]}"; do
            debug "${_k} = ${_arr[${_k}]}"
        done
    else
        info "Contents of \${${_arrayName}[@]}" "${_lineNumber}"

        for _k in "${!_arr[@]}"; do
            info "${_k} = ${_arr[${_k}]}"
        done
    fi
}
