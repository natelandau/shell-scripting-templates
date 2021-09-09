_execute_() {
    # DESC: Executes commands with safety and logging options
    # ARGS:  $1 (Required) - The command to be executed.  Quotation marks MUST be escaped.
    #        $2 (Optional) - String to display after command is executed
    # OPTS:  -v    Always print debug output from the execute function
    #        -n    Use NOTICE level alerting (default is INFO)
    #        -p    Pass a failed command with 'return 0'.  This effectively bypasses set -e.
    #        -e    Bypass _alert_ functions and use 'echo RESULT'
    #        -s    Use '_alert_ success' for successful output. (default is 'info')
    #        -q    Do not print output (QUIET mode)
    # OUTS:  None
    # USE :  _execute_ "cp -R \"~/dir/somefile.txt\" \"someNewFile.txt\"" "Optional message"
    #        _execute_ -sv "mkdir \"some/dir\""
    # NOTE:
    #         If $DRYRUN=true no commands are executed
    #         If $VERBOSE=true the command's native output is printed to
    #         stderr and stdin. This can be forced with `_execute_ -v`

    local LOCAL_VERBOSE=false
    local PASS_FAILURES=false
    local ECHO_RESULT=false
    local SUCCESS_RESULT=false
    local QUIET_RESULT=false
    local NOTICE_RESULT=false
    local opt

    local OPTIND=1
    while getopts ":vVpPeEsSqQnN" opt; do
        case $opt in
            v | V) LOCAL_VERBOSE=true ;;
            p | P) PASS_FAILURES=true ;;
            e | E) ECHO_RESULT=true ;;
            s | S) SUCCESS_RESULT=true ;;
            q | Q) QUIET_RESULT=true ;;
            n | N) NOTICE_RESULT=true ;;
            *)
                {
                    error "Unrecognized option '$1' passed to _execute_. Exiting."
                    _safeExit_
                }
                ;;
        esac
    done
    shift $((OPTIND - 1))

    local CMD="${1:?_execute_ needs a command}"
    local EXECUTE_MESSAGE="${2:-$1}"

    local SAVE_VERBOSE=${VERBOSE}
    if "${LOCAL_VERBOSE}"; then
        VERBOSE=true
    fi

    if "${DRYRUN}"; then
        if "${QUIET_RESULT}"; then
            VERBOSE=$SAVE_VERBOSE
            return 0
        fi
        if [ -n "${2:-}" ]; then
            dryrun "${1} (${2})" "$(caller)"
        else
            dryrun "${1}" "$(caller)"
        fi
    elif ${VERBOSE}; then
        if eval "${CMD}"; then
            if "${ECHO_RESULT}"; then
                echo "${EXECUTE_MESSAGE}"
            elif "${SUCCESS_RESULT}"; then
                success "${EXECUTE_MESSAGE}"
            elif "${NOTICE_RESULT}"; then
                notice "${EXECUTE_MESSAGE}"
            else
                info "${EXECUTE_MESSAGE}"
            fi
            VERBOSE=${SAVE_VERBOSE}
            return 0
        else
            if "${ECHO_RESULT}"; then
                echo "warning: ${EXECUTE_MESSAGE}"
            else
                warning "${EXECUTE_MESSAGE}"
            fi
            VERBOSE=${SAVE_VERBOSE}
            "${PASS_FAILURES}" && return 0 || return 1
        fi
    else
        if eval "${CMD}" &>/dev/null; then
            if "${QUIET_RESULT}"; then
                VERBOSE=${SAVE_VERBOSE}
                return 0
            elif "${ECHO_RESULT}"; then
                echo "${EXECUTE_MESSAGE}"
            elif "${SUCCESS_RESULT}"; then
                success "${EXECUTE_MESSAGE}"
            elif "${NOTICE_RESULT}"; then
                notice "${EXECUTE_MESSAGE}"
            else
                info "${EXECUTE_MESSAGE}"
            fi
            VERBOSE=${SAVE_VERBOSE}
            return 0
        else
            if "${ECHO_RESULT}"; then
                echo "error: ${EXECUTE_MESSAGE}"
            else
                warning "${EXECUTE_MESSAGE}"
            fi
            VERBOSE=${SAVE_VERBOSE}
            "${PASS_FAILURES}" && return 0 || return 1
        fi
    fi
}

_findBaseDir_() {
    # DESC: Locates the real directory of the script being run. Similar to GNU readlink -n
    # ARGS:  None
    # OUTS:  Echo result to STDOUT
    # USE :  baseDir="$(_findBaseDir_)"
    #        cp "$(_findBaseDir_ "somefile.txt")" "other_file.txt"

    local SOURCE
    local DIR

    # Is file sourced?
    [[ $_ != "$0" ]] \
        && SOURCE="${BASH_SOURCE[1]}" \
        || SOURCE="${BASH_SOURCE[0]}"

    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    echo "$(cd -P "$(dirname "${SOURCE}")" && pwd)"
}

_checkBinary_() {
    # DESC:  Check if a binary exists in the search PATH
    # ARGS:   $1 (Required) - Name of the binary to check for existence
    # OUTS:   true/false
    # USAGE:  (_checkBinary_ ffmpeg ) && [SUCCESS] || [FAILURE]
    if [[ $# -lt 1 ]]; then
        error 'Missing required argument to _checkBinary_()!'
        return 1
    fi

    if ! command -v "$1" >/dev/null 2>&1; then
        debug "Did not find dependency: '$1'"
        return 1
    fi
    return 0
}

_haveFunction_() {
    # DESC: Tests if a function exists.
    # ARGS:  $1 (Required) - Function name
    # OUTS:  true/false
    local f
    f="$1"

    if declare -f "${f}" &>/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

_pauseScript_() {
    # DESC:  Pause a script at any point and continue after user input
    # ARGS:  $1 (Optional) - String for customized message
    # OUTS:  None

    local pauseMessage
    pauseMessage="${1:-Paused}. Ready to continue?"

    if _seekConfirmation_ "${pauseMessage}"; then
        info "Continuing..."
    else
        notice "Exiting Script"
        _safeExit_
    fi
}

_progressBar_() {
    # DESC:  Prints a progress bar within a for/while loop
    # ARGS:  $1 (Required) - The total number of items counted
    #        $2 (Optional) - The optional title of the progress bar
    # OUTS:  None
    # USAGE:
    #   for number in $(seq 0 100); do
    #     sleep 1
    #     _progressBar_ "100" "Counting numbers"
    #   done

    ($QUIET) && return
    ($VERBOSE) && return
    [ ! -t 1 ] && return # Do nothing if the output is not a terminal
    [ $1 == 1 ] && return # Do nothing with a single element

    local width bar_char perc num bar progressBarLine barTitle n

    n="${1:?_progressBar_ needs input}"
    ((n = n - 1))
    barTitle="${2:-Running Process}"
    width=30
    bar_char="#"

    # Reset the count
    [ -z "${progressBarProgress}" ] && progressBarProgress=0
    tput civis # Hide the cursor
    trap 'tput cnorm; exit 1' SIGINT

    if [ ! "${progressBarProgress}" -eq $n ]; then
        #echo "progressBarProgress: $progressBarProgress"
        # Compute the percentage.
        perc=$((progressBarProgress * 100 / $1))
        # Compute the number of blocks to represent the percentage.
        num=$((progressBarProgress * width / $1))
        # Create the progress bar string.
        bar=""
        if [ ${num} -gt 0 ]; then
            bar=$(printf "%0.s${bar_char}" $(seq 1 ${num}))
        fi
        # Print the progress bar.
        progressBarLine=$(printf "%s [%-${width}s] (%d%%)" "  ${barTitle}" "${bar}" "${perc}")
        echo -ne "${progressBarLine}\r"
        progressBarProgress=$((progressBarProgress + 1))
    else
        # Clear the progress bar when complete
        # echo -ne "\033[0K\r"
        tput el # Clear the line

        unset progressBarProgress
    fi

    tput cnorm
}

_rootAvailable_() {
    # DESC: Validate we have superuser access as root (via sudo if requested)
    # ARGS: $1 (optional): Set to any value to not attempt root access via sudo
    # OUTS: None
    # NOTE: https://github.com/ralish/bash-script-template

    local superuser
    if [[ ${EUID} -eq 0 ]]; then
        superuser=true
    elif [[ -z ${1:-} ]]; then
        if command -v sudo &>/dev/null; then
            debug 'Sudo: Updating cached credentials ...'
            if ! sudo -v; then
                warning "Sudo: Couldn't acquire credentials ..."
            else
                local test_euid
                test_euid="$(sudo -H -- "$BASH" -c 'printf "%s" "$EUID"')"
                if [[ ${test_euid} -eq 0 ]]; then
                    superuser=true
                fi
            fi
        fi
    fi

    if [[ -z ${superuser:-} ]]; then
        debug 'Unable to acquire superuser credentials.'
        return 1
    fi

    debug 'Successfully acquired superuser credentials.'
    return 0
}

_runAsRoot_() {
    # DESC: Run the requested command as root (via sudo if requested)
    # ARGS: $1 (optional): Set to zero to not attempt execution via sudo
    #       $@ (required): Passed through for execution as root user
    # OUTS: None
    # NOTE: https://github.com/ralish/bash-script-template

    if [[ $# -eq 0 ]]; then
        fatal 'Missing required argument to _runAsRoot_()!'
    fi

    if [[ ${1:-} =~ ^0$ ]]; then
        local skip_sudo=true
        shift
    fi

    if [[ ${EUID} -eq 0 ]]; then
        "$@"
    elif [[ -z ${skip_sudo:-} ]]; then
        sudo -H -- "$@"
    else
        fatal "Unable to run requested command as root: $*"
    fi
}

_seekConfirmation_() {
    # DESC:  Seek user input for yes/no question
    # ARGS:   $1 (Optional) - Question being asked
    # OUTS:   true/false
    # USAGE:  _seekConfirmation_ "Do something?" && echo "okay" || echo "not okay"
    #         OR
    #         if _seekConfirmation_ "Answer this question"; then
    #           something
    #         fi

    input "${1:-}"
    if "${FORCE}"; then
        debug "Forcing confirmation with '--force' flag set"
        echo -e ""
        return 0
    else
        while true; do
            read -r -p " (y/n) " yn
            case $yn in
                [Yy]*) return 0 ;;
                [Nn]*) return 1 ;;
                *) input "Please answer yes or no." ;;
            esac
        done
    fi
}

_setPATH_() {
    # DESC:   Add directories to $PATH so script can find executables
    # ARGS:   $@ - One or more paths
    # OUTS:   $PATH
    # USAGE:  _setPATH_ "/usr/local/bin" "${HOME}/bin" "$(npm bin)"
    local NEWPATH NEWPATHS USERPATH

    for USERPATH in "$@"; do
        NEWPATHS+=("$USERPATH")
    done

    for NEWPATH in "${NEWPATHS[@]}"; do
        if [ -d "${NEWPATH}" ]; then
            if ! echo "$PATH" | grep -Eq "(^|:)${NEWPATH}($|:)"; then
                PATH="${NEWPATH}:${PATH}"
                debug "Added '${NEWPATH}' to PATH"
            fi
        fi
    done
}

_safeExit_() {
    # DESC: Cleanup and exit from a script
    # ARGS: $1 (optional) - Exit code (defaults to 0)
    # OUTS: None

    if [[ -d ${SCRIPT_LOCK:-} ]]; then
        if command rm -rf "${SCRIPT_LOCK}"; then
            debug "Removing script lock"
        else
            warning "Script lock could not be removed. Try manually deleting ${tan}'${LOCK_DIR}'${red}"
        fi
    fi

    if [[ -n ${TMP_DIR:-} && -d ${TMP_DIR:-}   ]]; then
        if [[ ${1:-} == 1 && -n "$(ls "${TMP_DIR}")" ]]; then
            command rm -r "${TMP_DIR}"
        else
            command rm -r "${TMP_DIR}"
            debug "Removing temp directory"
        fi
    fi

    trap - INT TERM EXIT
    exit ${1:-0}
}
