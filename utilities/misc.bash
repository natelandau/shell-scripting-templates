# Functions which provide base functionality for other scripts

_checkTerminalSize_() {
    # DESC:
    #					Checks the size of the terminal window.  Updates LINES/COLUMNS if necessary
    # ARGS:
    #					NONE
    # OUTS:
    #					NONE
    # USAGE:
    #					_updateTerminalSize_
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    shopt -s checkwinsize && (: && :)
    trap 'shopt -s checkwinsize; (:;:)' SIGWINCH
}

_detectOS_() {
    # DESC:
    #					Identify the OS the script is run on
    # ARGS:
    #					None
    # OUTS:
    #					0 - Success
    #					1 - Failed to detect OS
    #					stdout: One of 'mac', 'linux', 'windows'
    # USAGE:
    #					_detectOS_
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    local _uname
    local _os
    if _uname=$(command -v uname); then
        case $("${_uname}" | tr '[:upper:]' '[:lower:]') in
            linux*)
                _os="linux"
                ;;
            darwin*)
                _os="mac"
                ;;
            msys* | cygwin* | mingw* | nt | win*)
                # or possible 'bash on windows'
                _os="windows"
                ;;
            *)
                return 1
                ;;
        esac
    else
        return 1
    fi
    printf "%s" "${_os}"

}

_detectLinuxDistro_() {
    # DESC:
    #					Detects the Linux distribution of the host the script is run on
    # ARGS:
    #					None
    # OUTS:
    #					0 - If Linux distro is successfully detected
    #					1 - If unable to detect OS distro or not on Linux
    #					stdout: Prints name of Linux distro in lower case (ex: 'raspbian' or 'debian')
    # USAGE:
    #					_detectLinuxDistro_
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    local _distro
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091,SC2154
        . "/etc/os-release"
        _distro="${NAME}"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        _distro=$(lsb_release -si)
    elif [[ -f /etc/lsb-release ]]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        # shellcheck disable=SC1091,SC2154
        . /etc/lsb-release
        _distro="${DISTRIB_ID}"
    elif [[ -f /etc/debian_version ]]; then
        # Older Debian/Ubuntu/etc.
        _distro="debian"
    elif [[ -f /etc/SuSe-release ]]; then
        # Older SuSE/etc.
        _distro="suse"
    elif [[ -f /etc/redhat-release ]]; then
        # Older Red Hat, CentOS, etc.
        _distro="redhat"
    else
        return 1
    fi
    printf "%s" "${_distro}" | tr '[:upper:]' '[:lower:]'
}

_detectMacOSVersion_() {
    # DESC:
    #					Detects the host's version of MacOS
    # ARGS:
    #         None
    # OUTS:
    #					0 - Success
    #					1 - Can not find macOS version number or not on a mac
    #					stdout: Prints the version number of macOS (ex: 11.6.1)
    # USAGE:
    #					_detectMacOSVersion_
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    declare -f _detectOS_ &>/dev/null || fatal "${FUNCNAME[0]} needs function _detectOS_"

    if [[ "$(_detectOS_)" == "mac" ]]; then
        local _mac_version
        _mac_version="$(sw_vers -productVersion)"
        printf "%s" "${_mac_version}"
    else
        return 1
    fi
}

_detectLinuxDistro_() {
    # DESC:
    #					Detects the Linux distribution of the host the script is run on
    # ARGS:
    #					None
    # OUTS:
    #					0 - If Linux distro is successfully detected
    #					1 - If unable to detect OS distro or not on Linux
    #					stdout: Prints name of Linux distro in lower case (ex: 'raspbian' or 'debian')
    # USAGE:
    #					_detectLinuxDistro_
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    local _distro
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . "/etc/os-release"
        _distro="${NAME}"
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        _distro=$(lsb_release -si)
    elif [[ -f /etc/lsb-release ]]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        # shellcheck disable=SC1091
        . /etc/lsb-release
        _distro="${DISTRIB_ID}"
    elif [[ -f /etc/debian_version ]]; then
        # Older Debian/Ubuntu/etc.
        _distro="debian"
    elif [[ -f /etc/SuSe-release ]]; then
        # Older SuSE/etc.
        _distro="suse"
    elif [[ -f /etc/redhat-release ]]; then
        # Older Red Hat, CentOS, etc.
        _distro="redhat"
    else
        return 1
    fi
    printf "%s" "${_distro}" | tr '[:upper:]' '[:lower:]'
}

_execute_() {
    # DESC:
    #         Executes commands while respecting global DRYRUN, VERBOSE, LOGGING, and QUIET flags
    # ARGS:
    #         $1 (Required) - The command to be executed.  Quotation marks MUST be escaped.
    #         $2 (Optional) - String to display after command is executed
    # OPTS:
    #         -v    Always print output from the execute function to STDOUT
    #         -n    Use NOTICE level alerting (default is INFO)
    #         -p    Pass a failed command with 'return 0'.  This effectively bypasses set -e.
    #         -e    Bypass _alert_ functions and use 'printf RESULT'
    #         -s    Use '_alert_ success' for successful output. (default is 'info')
    #         -q    Do not print output (QUIET mode)
    # OUTS:
    #         stdout: Configurable output
    # USE :
    #         _execute_ "cp -R \"~/dir/somefile.txt\" \"someNewFile.txt\"" "Optional message"
    #         _execute_ -sv "mkdir \"some/dir\""
    # NOTE:
    #         If $DRYRUN=true, no commands are executed and the command that would have been executed
    #         is printed to STDOUT using dryrun level alerting
    #         If $VERBOSE=true, the command's native output is printed to stdout. This can be forced
    #         with '_execute_ -v'

    local _localVerbose=false
    local _passFailures=false
    local _echoResult=false
    local _echoSuccessResult=false
    local _quietMode=false
    local _echoNoticeResult=false
    local opt

    local OPTIND=1
    while getopts ":vVpPeEsSqQnN" opt; do
        case ${opt} in
            v | V) _localVerbose=true ;;
            p | P) _passFailures=true ;;
            e | E) _echoResult=true ;;
            s | S) _echoSuccessResult=true ;;
            q | Q) _quietMode=true ;;
            n | N) _echoNoticeResult=true ;;
            *)
                {
                    error "Unrecognized option '$1' passed to _execute_. Exiting."
                    _safeExit_
                }
                ;;
        esac
    done
    shift $((OPTIND - 1))

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _command="${1}"
    local _executeMessage="${2:-$1}"

    local _saveVerbose=${VERBOSE}
    if "${_localVerbose}"; then
        VERBOSE=true
    fi

    if "${DRYRUN:-}"; then
        if "${_quietMode}"; then
            VERBOSE=${_saveVerbose}
            return 0
        fi
        if [ -n "${2:-}" ]; then
            dryrun "${1} (${2})" "$(caller)"
        else
            dryrun "${1}" "$(caller)"
        fi
    elif ${VERBOSE:-}; then
        if eval "${_command}"; then
            if "${_quietMode}"; then
                VERBOSE=${_saveVerbose}
            elif "${_echoResult}"; then
                printf "%s\n" "${_executeMessage}"
            elif "${_echoSuccessResult}"; then
                success "${_executeMessage}"
            elif "${_echoNoticeResult}"; then
                notice "${_executeMessage}"
            else
                info "${_executeMessage}"
            fi
        else
            if "${_quietMode}"; then
                VERBOSE=${_saveVerbose}
            elif "${_echoResult}"; then
                printf "%s\n" "warning: ${_executeMessage}"
            else
                warning "${_executeMessage}"
            fi
            VERBOSE=${_saveVerbose}
            "${_passFailures}" && return 0 || return 1
        fi
    else
        if eval "${_command}" >/dev/null 2>&1; then
            if "${_quietMode}"; then
                VERBOSE=${_saveVerbose}
            elif "${_echoResult}"; then
                printf "%s\n" "${_executeMessage}"
            elif "${_echoSuccessResult}"; then
                success "${_executeMessage}"
            elif "${_echoNoticeResult}"; then
                notice "${_executeMessage}"
            else
                info "${_executeMessage}"
            fi
        else
            if "${_quietMode}"; then
                VERBOSE=${_saveVerbose}
            elif "${_echoResult}"; then
                printf "%s\n" "error: ${_executeMessage}"
            else
                warning "${_executeMessage}"
            fi
            VERBOSE=${_saveVerbose}
            "${_passFailures}" && return 0 || return 1
        fi
    fi
    VERBOSE=${_saveVerbose}
    return 0
}

_findBaseDir_() {
    # DESC:
    #         Locates the real directory of the script being run. Similar to GNU readlink -n
    # ARGS:
    #         None
    # OUTS:
    #         stdout: prints result
    # USAGE:
    #         baseDir="$(_findBaseDir_)"
    #         cp "$(_findBaseDir_ "somefile.txt")" "other_file.txt"

    local _source
    local _dir

    # Is file sourced?
    if [[ ${_} != "${0}" ]]; then
        _source="${BASH_SOURCE[1]}"
    else
        _source="${BASH_SOURCE[0]}"
    fi

    while [ -h "${_source}" ]; do # Resolve $SOURCE until the file is no longer a symlink
        _dir="$(cd -P "$(dirname "${_source}")" && pwd)"
        _source="$(readlink "${_source}")"
        [[ ${_source} != /* ]] && _source="${_dir}/${_source}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    printf "%s\n" "$(cd -P "$(dirname "${_source}")" && pwd)"
}

_generateUUID_() {
    # DESC:
    #					Generates a UUID
    # ARGS:
    #					None
    # OUTS:
    #					0 - Success
    #					1 - Failure
    #					stdout: UUID
    # USAGE:
    #					_generateUUID_
    # CREDIT:
    #         https://github.com/labbots/bash-utility

    local _c
    local n
    local _b
    _c="89ab"

    for ((n = 0; n < 16; ++n)); do
        _b="$((RANDOM % 256))"

        case "${n}" in
            6) printf '4%x' "$((_b % 16))" ;;
            8) printf '%c%x' "${_c:${RANDOM}%${#_c}:1}" "$((_b % 16))" ;;

            3 | 5 | 7 | 9)
                printf '%02x-' "${_b}"
                ;;

            *)
                printf '%02x' "${_b}"
                ;;
        esac
    done

    printf '\n'
}

_progressBar_() {
    # DESC:
    #         Prints a progress bar within a for/while loop. For this to work correctly you
    #         MUST know the exact number of iterations. If you don't know the exact number use _spinner_
    # ARGS:
    #         $1 (Required) - The total number of items counted
    #         $2 (Optional) - The optional title of the progress bar
    # OUTS:
    #         stdout: progress bar
    # USAGE:
    #         for i in $(seq 0 100); do
    #             sleep 0.1
    #             _makeProgressBar_ "100" "Counting numbers"
    #         done

    [[ $# == 0 ]] && return   # Do nothing if no arguments are passed
    (${QUIET:-}) && return    # Do nothing in quiet mode
    (${VERBOSE:-}) && return  # Do nothing if verbose mode is enabled
    [ ! -t 1 ] && return      # Do nothing if the output is not a terminal
    [[ ${1} == 1 ]] && return # Do nothing with a single element

    local _n="${1}"
    local _width=30
    local _barCharacter="#"
    local _percentage
    local _num
    local _bar
    local _progressBarLine
    local _barTitle="${2:-Running Process}"

    ((_n = _n - 1))

    # Reset the count
    [ -z "${PROGRESS_BAR_PROGRESS:-}" ] && PROGRESS_BAR_PROGRESS=0

    # Hide the cursor
    tput civis

    if [[ ! ${PROGRESS_BAR_PROGRESS} -eq ${_n} ]]; then

        # Compute the percentage.
        _percentage=$((PROGRESS_BAR_PROGRESS * 100 / $1))

        # Compute the number of blocks to represent the percentage.
        _num=$((PROGRESS_BAR_PROGRESS * _width / $1))

        # Create the progress bar string.
        _bar=""
        if [[ ${_num} -gt 0 ]]; then
            _bar=$(printf "%0.s${_barCharacter}" $(seq 1 "${_num}"))
        fi

        # Print the progress bar.
        _progressBarLine=$(printf "%s [%-${_width}s] (%d%%)" "  ${_barTitle}" "${_bar}" "${_percentage}")
        printf "%s\r" "${_progressBarLine}"

        PROGRESS_BAR_PROGRESS=$((PROGRESS_BAR_PROGRESS + 1))

    else
        # Replace the cursor
        tput cnorm

        # Clear the progress bar when complete
        printf "\r\033[0K"

        unset PROGRESS_BAR_PROGRESS
    fi

}

_spinner_() {
    # DESC:
    #					Creates a spinner within a for/while loop.
    #         Don't forget to add _endspin_ at the end of the loop
    # ARGS:
    #					$1 (Optional) - Text accompanying the spinner
    # OUTS:
    #					stdout: progress bar
    # USAGE:
    #         for i in $(seq 0 100); do
    #             sleep 0.1
    #             _spinner_ "Counting numbers"
    #         done
    #         _endspin_

    (${QUIET:-}) && return   # Do nothing in quiet mode
    (${VERBOSE:-}) && return # Do nothing in verbose mode
    [ ! -t 1 ] && return     # Do nothing if the output is not a terminal

    local _message
    _message="${1:-Running process}"

    # Hide the cursor
    tput civis

    [[ -z ${SPIN_NUM:-} ]] && SPIN_NUM=0

    case ${SPIN_NUM:-} in
        0) _glyph="█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        1) _glyph="█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        2) _glyph="██▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        3) _glyph="███▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        4) _glyph="████▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        5) _glyph="██████▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        6) _glyph="██████▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        7) _glyph="███████▁▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        8) _glyph="████████▁▁▁▁▁▁▁▁▁▁▁▁" ;;
        9) _glyph="█████████▁▁▁▁▁▁▁▁▁▁▁" ;;
        10) _glyph="█████████▁▁▁▁▁▁▁▁▁▁▁" ;;
        11) _glyph="██████████▁▁▁▁▁▁▁▁▁▁" ;;
        12) _glyph="███████████▁▁▁▁▁▁▁▁▁" ;;
        13) _glyph="█████████████▁▁▁▁▁▁▁" ;;
        14) _glyph="██████████████▁▁▁▁▁▁" ;;
        15) _glyph="██████████████▁▁▁▁▁▁" ;;
        16) _glyph="███████████████▁▁▁▁▁" ;;
        17) _glyph="███████████████▁▁▁▁▁" ;;
        18) _glyph="███████████████▁▁▁▁▁" ;;
        19) _glyph="████████████████▁▁▁▁" ;;
        20) _glyph="█████████████████▁▁▁" ;;
        21) _glyph="█████████████████▁▁▁" ;;
        22) _glyph="██████████████████▁▁" ;;
        23) _glyph="██████████████████▁▁" ;;
        24) _glyph="███████████████████▁" ;;
        25) _glyph="███████████████████▁" ;;
        26) _glyph="███████████████████▁" ;;
        27) _glyph="████████████████████" ;;
        28) _glyph="████████████████████" ;;
    esac

    # shellcheck disable=SC2154
    printf "\r${gray}[   info] %s  %s...${reset}" "${_glyph}" "${_message}"
    if [[ ${SPIN_NUM} -lt 28 ]]; then
        ((SPIN_NUM = SPIN_NUM + 1))
    else
        SPIN_NUM=0
    fi
}

_endspin_() {
    # DESC:
    #         Clears the line that showed the spinner and replaces the cursor. To be run after _spinner_
    # ARGS:
    #					None
    # OUTS:
    #					stdout:  Removes previous line
    # USAGE:
    #					_endspin_

    # Clear the spinner
    printf "\r\033[0K"

    # Replace the cursor
    tput cnorm

    unset SPIN_NUM
}

_runAsRoot_() {
    # DESC:
    #         Run the requested command as root (via sudo if requested)
    # ARGS:
    #         $1 (optional): Set to zero to not attempt execution via sudo
    #         $@ (required): Passed through for execution as root user
    # OUTS:
    #         Runs the requested command as root
    # CREDIT:
    #         https://github.com/ralish/bash-script-template

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _skip_sudo=false

    if [[ ${1} =~ ^0$ ]]; then
        _skip_sudo=true
        shift
    fi

    if [[ ${EUID} -eq 0 ]]; then
        "$@"
    elif [[ -z ${_skip_sudo} ]]; then
        sudo -H -- "$@"
    else
        fatal "Unable to run requested command as root: $*"
    fi
}

_seekConfirmation_() {
    # DESC:
    #         Seek user input for yes/no question
    # ARGS:
    #         $1 (Required) - Question being asked
    # OUTS:
    #         0 if answer is "yes"
    #         1 if answer is "no"
    # USAGE:
    #         _seekConfirmation_ "Do something?" && printf "okay" || printf "not okay"
    #         OR
    #         if _seekConfirmation_ "Answer this question"; then
    #           something
    #         fi

    [[ $# == 0 ]] && fatal "Missing required argument to ${FUNCNAME[0]}"

    local _yesNo
    input "${1}"
    if "${FORCE:-}"; then
        debug "Forcing confirmation with '--force' flag set"
        printf "%s\n" " "
        return 0
    else
        while true; do
            read -r -p " (y/n) " _yesNo
            case ${_yesNo} in
                [Yy]*) return 0 ;;
                [Nn]*) return 1 ;;
                *) input "Please answer yes or no." ;;
            esac
        done
    fi
}
