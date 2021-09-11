#!/usr/bin/env bash

_mainScript_() {

    # Replace everything in _mainScript_() with your script's code
    header "Showing alert colors"
    debug "This is debug text"
    info "This is info text"
    notice "This is notice text"
    dryrun "This is dryrun text"
    warning "This is warning text"
    error "This is error text"
    success "This is success text"
    input "This is input text"

} # end _mainScript_

# ################################## Flags and defaults
# Script specific

# Common
LOGFILE="${HOME}/logs/$(basename "$0").log"
QUIET=false
LOGLEVEL=ERROR
VERBOSE=false
FORCE=false
DRYRUN=false
declare -a ARGS=()
NOW=$(LC_ALL=C date +"%m-%d-%Y %r")                   # Returns: 06-14-2015 10:34:40 PM
DATESTAMP=$(LC_ALL=C date +%Y-%m-%d)                  # Returns: 2015-06-14
HOURSTAMP=$(LC_ALL=C date +%r)                        # Returns: 10:34:40 PM
TIMESTAMP=$(LC_ALL=C date +%Y%m%d_%H%M%S)             # Returns: 20150614_223440
LONGDATE=$(LC_ALL=C date +"%a, %d %b %Y %H:%M:%S %z") # Returns: Sun, 10 Jan 2016 20:47:53 -0500
GMTDATE=$(LC_ALL=C date -u -R | sed 's/\+0000/GMT/')  # Returns: Wed, 13 Jan 2016 15:55:29 GMT

# ################################## Custom utility functions

# ################################## Common Functions for script template

_setColors_() {
    # DESC: Sets colors use for alerts.
    # ARGS:		None
    # OUTS:		None
    # USAGE:  echo "${blue}Some text${reset}"

    if tput setaf 1 &>/dev/null; then
        bold=$(tput bold)
        underline=$(tput smul)
        reverse=$(tput rev)
        reset=$(tput sgr0)

        if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
            white=$(tput setaf 231)
            blue=$(tput setaf 38)
            yellow=$(tput setaf 11)
            tan=$(tput setaf 3)
            green=$(tput setaf 82)
            red=$(tput setaf 1)
            purple=$(tput setaf 171)
            gray=$(tput setaf 250)
        else
            white=$(tput setaf 7)
            blue=$(tput setaf 38)
            yellow=$(tput setaf 3)
            tan=$(tput setaf 3)
            green=$(tput setaf 2)
            red=$(tput setaf 1)
            purple=$(tput setaf 13)
            gray=$(tput setaf 7)
        fi
    else
        bold="\033[4;37m"
        reset="\033[0m"
        underline="\033[4;37m"
        reverse=""
        white="\033[0;37m"
        blue="\033[0;34m"
        yellow="\033[0;33m"
        tan="\033[0;33m"
        green="\033[1;32m"
        red="\033[0;31m"
        purple="\033[0;35m"
        gray="\033[0;37m"
    fi
}

_alert_() {
    # DESC:   Controls all printing of messages to log files and stdout.
    # ARGS:   $1 (required) - The type of alert to print
    #                         (success, header, notice, dryrun, debug, warning, error,
    #                         fatal, info, input)
    #         $2 (required) - The message to be printed to stdout and/or a log file
    #         $3 (optional) - Pass '${LINENO}' to print the line number where the _alert_ was triggered
    # OUTS:   None
    # USAGE:  [ALERTTYPE] "[MESSAGE]" "${LINENO}"
    # NOTES:  The colors of each alert type are set in this function
    #         For specified alert types, the funcstac will be printed

    local function_name color
    local alertType="${1}"
    local message="${2}"
    local line="${3:-}" # Optional line number

    if [[ -n ${line} && ${alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        message="${message} (line: ${line}) $(_functionStack_)"
    elif [[ -n ${line} && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        message="${message} (line: ${line})"
    elif [[ -z ${line} && ${alertType} =~ ^(fatal|error) && ${FUNCNAME[2]} != "_trapCleanup_" ]]; then
        message="${message} $(_functionStack_)"
    fi

    if [[ ${alertType} =~ ^(error|fatal) ]]; then
        color="${bold}${red}"
    elif [ "${alertType}" == "info" ]; then
        color="${gray}"
    elif [ "${alertType}" == "warning" ]; then
        color="${red}"
    elif [ "${alertType}" == "success" ]; then
        color="${green}"
    elif [ "${alertType}" == "debug" ]; then
        color="${purple}"
    elif [ "${alertType}" == "header" ]; then
        color="${bold}${tan}"
    elif [ ${alertType} == "notice" ]; then
        color="${bold}"
    elif [ ${alertType} == "input" ]; then
        color="${bold}${underline}"
    elif [ "${alertType}" = "dryrun" ]; then
        color="${blue}"
    else
        color=""
    fi

    _writeToScreen_() {

        ("${QUIET}") && return 0 # Print to console when script is not 'quiet'
        [[ ${VERBOSE} == false && ${alertType} =~ ^(debug|verbose) ]] && return 0

        if ! [[ -t 1 ]]; then # Don't use colors on non-recognized terminals
            color=""
            reset=""
        fi

        echo -e "$(date +"%r") ${color}$(printf "[%7s]" "${alertType}") ${message}${reset}"
    }
    _writeToScreen_

    _writeToLog_() {
        [[ ${alertType} == "input" ]] && return 0
        [[ ${LOGLEVEL} =~ (off|OFF|Off) ]] && return 0
        if [ -z "${LOGFILE:-}" ]; then
            LOGFILE="$(pwd)/$(basename "$0").log"
        fi
        [ ! -d "$(dirname "${LOGFILE}")" ] && mkdir -p "$(dirname "${LOGFILE}")"
        [[ ! -f ${LOGFILE} ]] && touch "${LOGFILE}"

        # Don't use colors in logs
        if command -v gsed &>/dev/null; then
            local cleanmessage="$(echo "${message}" | gsed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
        else
            local cleanmessage="$(echo "${message}" | sed -E 's/(\x1b)?\[(([0-9]{1,2})(;[0-9]{1,3}){0,2})?[mGK]//g')"
        fi
        echo -e "$(date +"%b %d %R:%S") $(printf "[%7s]" "${alertType}") [$(/bin/hostname)] ${cleanmessage}" >>"${LOGFILE}"
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
            if [[ ${alertType} =~ ^(die|error|fatal|warning|info|notice|success) ]]; then
                _writeToLog_
            fi
            ;;
        NOTICE | notice | Notice)
            if [[ ${alertType} =~ ^(die|error|fatal|warning|notice|success) ]]; then
                _writeToLog_
            fi
            ;;
        WARN | warn | Warn)
            if [[ ${alertType} =~ ^(die|error|fatal|warning) ]]; then
                _writeToLog_
            fi
            ;;
        ERROR | error | Error)
            if [[ ${alertType} =~ ^(die|error|fatal) ]]; then
                _writeToLog_
            fi
            ;;
        FATAL | fatal | Fatal)
            if [[ ${alertType} =~ ^(die|fatal) ]]; then
                _writeToLog_
            fi
            ;;
        OFF | off)
            return 0
            ;;
        *)
            if [[ ${alertType} =~ ^(die|error|fatal) ]]; then
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
header() { _alert_ header "== ${1} ==" "${2:-}"; }
debug() { _alert_ debug "${1}" "${2:-}"; }
die() {
    _alert_ fatal "${1}" "${2:-}"
    _safeExit_ "1"
}
fatal() {
    _alert_ fatal "${1}" "${2:-}"
    _safeExit_ "1"
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

    if [[ -n ${TMP_DIR:-} && -d ${TMP_DIR:-} ]]; then
        if [[ ${1:-} == 1 && -n "$(ls "${TMP_DIR}")" ]]; then
            # Do something here to save TMP_DIR on a non-zero script exit for debugging
            command rm -r "${TMP_DIR}"
            debug "Removing temp directory"
        else
            command rm -r "${TMP_DIR}"
            debug "Removing temp directory"
        fi
    fi

    trap - INT TERM EXIT
    exit ${1:-0}
}

_trapCleanup_() {
    # DESC:  Log errors and cleanup from script when an error is trapped
    # ARGS:   $1 - Line number where error was trapped
    #         $2 - Line number in function
    #         $3 - Command executing at the time of the trap
    #         $4 - Names of all shell functions currently in the execution call stack
    #         $5 - Scriptname
    #         $6 - $BASH_SOURCE
    # OUTS:   None

    local line=${1:-} # LINENO
    local linecallfunc=${2:-}
    local command="${3:-}"
    local funcstack="${4:-}"
    local script="${5:-}"
    local sourced="${6:-}"

    funcstack="'$(echo "$funcstack" | sed -E 's/ / < /g')'"

    if [[ ${script##*/} == "${sourced##*/}" ]]; then
        fatal "${7:-} command: '${command}' (line: ${line}) [func: $(_functionStack_)]"
    else
        fatal "${7:-} command: '${command}' (func: ${funcstack} called at line ${linecallfunc} of '${script##*/}') (line: $line of '${sourced##*/}') "
    fi

    _safeExit_ "1"
}

_makeTempDir_() {
    # DESC:   Creates a temp directory to house temporary files
    # ARGS:   $1 (Optional) - First characters/word of directory name
    # OUTS:   $TMP_DIR       - Temporary directory
    # USAGE:  _makeTempDir_ "$(basename "$0")"

    [ -d "${TMP_DIR:-}" ] && return 0

    if [ -n "${1:-}" ]; then
        TMP_DIR="${TMPDIR:-/tmp/}${1}.$RANDOM.$RANDOM.$$"
    else
        TMP_DIR="${TMPDIR:-/tmp/}$(basename "$0").$RANDOM.$RANDOM.$RANDOM.$$"
    fi
    (umask 077 && mkdir "${TMP_DIR}") || {
        fatal "Could not create temporary directory! Exiting."
    }
    debug "\$TMP_DIR=${TMP_DIR}"
}

_acquireScriptLock_() {
    # DESC: Acquire script lock
    # ARGS: $1 (optional) - Scope of script execution lock (system or user)
    # OUTS: $SCRIPT_LOCK - Path to the directory indicating we have the script lock
    # NOTE: This lock implementation is extremely simple but should be reliable
    #       across all platforms. It does *not* support locking a script with
    #       symlinks or multiple hardlinks as there's no portable way of doing so.
    #       If the lock was acquired it's automatically released in _safeExit_()

    local LOCK_DIR
    if [[ ${1:-} == 'system' ]]; then
        LOCK_DIR="${TMPDIR:-/tmp/}$(basename "$0").lock"
    else
        LOCK_DIR="${TMPDIR:-/tmp/}$(basename "$0").$UID.lock"
    fi

    if command mkdir "${LOCK_DIR}" 2>/dev/null; then
        readonly SCRIPT_LOCK="${LOCK_DIR}"
        debug "Acquired script lock: ${tan}${SCRIPT_LOCK}${purple}"
    else
        error "Unable to acquire script lock: ${tan}${LOCK_DIR}${red}"
        fatal "If you trust the script isn't running, delete the lock dir"
    fi
}

_functionStack_() {
    # DESC:   Prints the function stack in use
    # ARGS:   None
    # OUTS:   Prints [function]:[file]:[line]
    # NOTE:   Does not print functions from the alert class
    local _i
    funcStackResponse=()
    for ((_i = 1; _i < ${#BASH_SOURCE[@]}; _i++)); do
        case "${FUNCNAME[$_i]}" in "_alert_" | "_trapCleanup_" | fatal | error | warning | notice | info | verbose | debug | dryrun | header | success | die) continue ;; esac
        funcStackResponse+=("${FUNCNAME[$_i]}:$(basename ${BASH_SOURCE[$_i]}):${BASH_LINENO[_i - 1]}")
    done
    printf "( "
    printf %s "${funcStackResponse[0]}"
    printf ' < %s' "${funcStackResponse[@]:1}"
    printf ' )\n'
}

_parseOptions_() {
    # Iterate over options
    # breaking -ab into -a -b when needed and --foo=bar into --foo bar
    optstring=h
    unset options
    while (($#)); do
        case $1 in
            # If option is of type -ab
            -[!-]?*)
                # Loop over each character starting with the second
                for ((i = 1; i < ${#1}; i++)); do
                    c=${1:i:1}
                    options+=("-$c") # Add current char to options
                    # If option takes a required argument, and it's not the last char make
                    # the rest of the string its argument
                    if [[ $optstring == *"$c:"* && ${1:i+1} ]]; then
                        options+=("${1:i+1}")
                        break
                    fi
                done
                ;;
            # If option is of type --foo=bar
            --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
            # add --endopts for --
            --) options+=(--endopts) ;;
            # Otherwise, nothing special
            *) options+=("$1") ;;
        esac
        shift
    done
    set -- "${options[@]:-}"
    unset options

    # Read the options and set stuff
    while [[ ${1:-} == -?* ]]; do
        case $1 in
            # Custom options

            # Common options
            -h | --help)
                _usage_ >&2
                _safeExit_
                ;;
            --loglevel)
                shift
                LOGLEVEL=${1}
                ;;
            --logfile)
                shift
                LOGFILE="${1}"
                ;;
            -n | --dryrun) DRYRUN=true ;;
            -v | --verbose) VERBOSE=true ;;
            -q | --quiet) QUIET=true ;;
            --force) FORCE=true ;;
            --endopts)
                shift
                break
                ;;
            *) fatal "invalid option: '$1'." ;;
        esac
        shift
    done
    ARGS+=("$@") # Store the remaining user input as arguments.
}

_usage_() {
    cat <<EOF

  ${bold}$(basename "$0") [OPTION]... [FILE]...${reset}

  This is a script template.  Edit this description to print help to users.

  ${bold}Options:${reset}
    -h, --help              Display this help and exit
    --loglevel [LEVEL]      One of: FATAL, ERROR, WARN, INFO, NOTICE, DEBUG, ALL, OFF
                            (Default is 'ERROR')
    --logfile [FILE]        Full PATH to logfile.  (Default is '${HOME}/logs/$(basename "$0").log')
    -n, --dryrun            Non-destructive. Makes no permanent changes.
    -q, --quiet             Quiet (no output)
    -v, --verbose           Output more information. (Items echoed to 'verbose')
    --force                 Skip all user interaction.  Implied 'Yes' to all actions.

  ${bold}Example Usage:${reset}

      $ $(basename "$0") -vn --logfile "/path/to/file.log" --loglevel 'WARN'
EOF
}

# ################################## INITIALIZE AND RUN THE SCRIPT
#                                    (Comment or uncomment the lines below to customize script behavior)

trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT

# Trap errors in subshells and functions
set -o errtrace

# Exit on error. Append '||true' if you expect an error
set -o errexit

# Use last non-zero exit code in a pipeline
set -o pipefail

# Make `for f in *.txt` work when `*.txt` matches zero files
# shopt -s nullglob globstar

# Set IFS to preferred implementation
IFS=$' \n\t'

# Run in debug mode
# set -o xtrace

# Initialize color constants
_setColors_

# Disallow expansion of unset variables
set -o nounset

# Force arguments when invoking the script
# [[ $# -eq 0 ]] && _parseOptions_ "-h"

# Parse arguments passed to script
_parseOptions_ "$@"

# Create a temp directory '$TMP_DIR'
# _makeTempDir_ "$(basename "$0")"

# Acquire script lock
# _acquireScriptLock_

# Run the main logic script
_mainScript_

# Exit cleanly
_safeExit_
