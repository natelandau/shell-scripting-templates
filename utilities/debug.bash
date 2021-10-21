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

    #echo $(tr -dc '[:print:]'<<<$1)
    printf "%s\n" "${1//$'\e'/\\e}"

}

_printArray_() {
    # DESC:
    #         Prints the content of array as key value pairs for easier debugging
    # ARGS:
    #         $1 (Required) - String variable name of the array
    # OUTS:
    #         stdout: Formatted key value of array.one
    # USAGE:
    #         testArray=("1" "2" "3" "4")
    #         _printArray_ "testArray"
    # CREDIT:
    #         https://github.com/labbots/bash-utility/blob/master/src/debug.sh

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    declare -n _arr="${1}"
    for _k in "${!_arr[@]}"; do
        printf "%s = %s\n" "$_k" "${_arr[$_k]}"
    done
}
