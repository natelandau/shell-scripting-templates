#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR/../shell-scripting-templates/utilities
# shellcheck source-path=SCRIPTDIR/../../shell-scripting-templates/utilities

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

}
#/_mainsScript_()

# ################################## Flags and defaults
# # Required variables
LOGFILE="${HOME}/logs/$(basename "$0").log"
QUIET=false
LOGLEVEL=ERROR
VERBOSE=false
FORCE=false
DRYRUN=false
declare -a ARGS=()

# Script specific

# ################################## Functions required for this template to work

_trapCleanup_() {
    # DESC:
    #         Log errors and cleanup from script when an error is trapped.  Called by 'trap'
    # ARGS:
    #         $1:  Line number where error was trapped
    #         $2:  Line number in function
    #         $3:  Command executing at the time of the trap
    #         $4:  Names of all shell functions currently in the execution call stack
    #         $5:  Scriptname
    #         $6:  $BASH_SOURCE
    # USAGE:
    #         trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
    # OUTS:
    #         Exits script with error code 1

    local _line=${1:-} # LINENO
    local _linecallfunc=${2:-}
    local _command="${3:-}"
    local _funcstack="${4:-}"
    local _script="${5:-}"
    local _sourced="${6:-}"

    # Replace the cursor in-case 'tput civis' has been used
    tput cnorm

    if declare -f "fatal" &>/dev/null && declare -f "_printFuncStack_" &>/dev/null; then

        _funcstack="'$(printf "%s" "${_funcstack}" | sed -E 's/ / < /g')'"

        if [[ ${_script##*/} == "${_sourced##*/}" ]]; then
            fatal "${7:-} command: '${_command}' (line: ${_line}) [func: $(_printFuncStack_)]"
        else
            fatal "${7:-} command: '${_command}' (func: ${_funcstack} called at line ${_linecallfunc} of '${_script##*/}') (line: ${_line} of '${_sourced##*/}') "
        fi
    else
        printf "%s\n" "Fatal error trapped. Exiting..."
    fi

    if declare -f _safeExit_ &>/dev/null; then
        _safeExit_ 1
    else
        exit 1
    fi
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

_sourceUtilities_() {
    # DESC:
    #         Sources utility functions.  Absolute paths are required for shellcheck to correctly
    #         parse the sourced files
    # ARGS:
    #					$1 (Required):  Absolute path to the directory containing the utilities
    # OUTS:
    #					 0:  Success
    #					 1:  Failure
    # USAGE:
    #					_sourceUtilities_ "$(_findBaseDir_)/../../shell-scripting-templates/utilities"

    local _utilsPath
    _utilsPath="${1}"

    if [ -f "${_utilsPath}/alerts.bash" ]; then
        source "${_utilsPath}/alerts.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/alerts.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/arrays.bash" ]; then
        source "${_utilsPath}/arrays.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/arrays.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/checks.bash" ]; then
        source "${_utilsPath}/checks.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/checks.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/dates.bash" ]; then
        source "${_utilsPath}/dates.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/dates.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/debug.bash" ]; then
        source "${_utilsPath}/debug.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/debug.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/files.bash" ]; then
        source "${_utilsPath}/files.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/files.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/macOS.bash" ]; then
        source "${_utilsPath}/macOS.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/macOS.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/misc.bash" ]; then
        source "${_utilsPath}/misc.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/misc.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/services.bash" ]; then
        source "${_utilsPath}/services.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/services.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/strings.bash" ]; then
        source "${_utilsPath}/strings.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/strings.bash not found"
        exit 1
    fi

    if [ -f "${_utilsPath}/template_utils.bash" ]; then
        source "${_utilsPath}/template_utils.bash"
    else
        printf "%s\n" "ERROR: ${_utilsPath}/template_utils.bash not found"
        exit 1
    fi
}

_parseOptions_() {
    # DESC:
    #					Iterates through options passed to script and sets variables. Will break -ab into -a -b
    #         when needed and --foo=bar into --foo bar
    # ARGS:
    #					$@ from command line
    # OUTS:
    #					Sets array 'ARGS' containing all arguments passed to script that were not parsed as options
    # USAGE:
    #					_parseOptions_ "$@"

    # Iterate over options
    local _optstring=h
    declare -a _options
    local _c
    local i
    while (($#)); do
        case $1 in
            # If option is of type -ab
            -[!-]?*)
                # Loop over each character starting with the second
                for ((i = 1; i < ${#1}; i++)); do
                    _c=${1:i:1}
                    _options+=("-${_c}") # Add current char to options
                    # If option takes a required argument, and it's not the last char make
                    # the rest of the string its argument
                    if [[ ${_optstring} == *"${_c}:"* && -n ${1:i+1} ]]; then
                        _options+=("${1:i+1}")
                        break
                    fi
                done
                ;;
            # If option is of type --foo=bar
            --?*=*) _options+=("${1%%=*}" "${1#*=}") ;;
            # add --endopts for --
            --) _options+=(--endopts) ;;
            # Otherwise, nothing special
            *) _options+=("$1") ;;
        esac
        shift
    done
    set -- "${_options[@]:-}"
    unset _options

    # Read the options and set stuff
    # shellcheck disable=SC2034
    while [[ ${1:-} == -?* ]]; do
        case $1 in
            # Custom options

            # Common options
            -h | --help)
                _usage_
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
            *)
                if declare -f _safeExit_ &>/dev/null; then
                    fatal "invalid option: $1"
                else
                    printf "%s\n" "ERROR: Invalid option: $1"
                    exit 1
                fi
                ;;
        esac
        shift
    done

    if [[ -z ${*} || ${*} == null ]]; then
        ARGS=()
    else
        ARGS+=("$@") # Store the remaining user input as arguments.
    fi
}

_usage_() {
    cat <<USAGE_TEXT

  ${bold}$(basename "$0") [OPTION]... [FILE]...${reset}

  This is a script template.  Edit this description to print help to users.

  ${bold}${underline}Options:${reset}
$(_columns_ -b -- '-h, --help' "Display this help and exit" 2)
$(_columns_ -b -- "--loglevel [LEVEL]" "One of: FATAL, ERROR (default), WARN, INFO, NOTICE, DEBUG, ALL, OFF" 2)
$(_columns_ -b -- "--logfile [FILE]" "Full PATH to logfile.  (Default is '\${HOME}/logs/$(basename "$0").log')" 2)
$(_columns_ -b -- "-n, --dryrun" "Non-destructive. Makes no permanent changes." 2)
$(_columns_ -b -- "-q, --quiet" "Quiet (no output)" 2)
$(_columns_ -b -- "-v, --verbose" "Output more information. (Items echoed to 'verbose')" 2)
$(_columns_ -b -- "--force" "Skip all user interaction.  Implied 'Yes' to all actions." 2)

  ${bold}${underline}Example Usage:${reset}

    ${gray}# Run the script and specify log level and log file.${reset}
    $(basename "$0") -vn --logfile "/path/to/file.log" --loglevel 'WARN'
USAGE_TEXT
}

# ################################## INITIALIZE AND RUN THE SCRIPT
#                                    (Comment or uncomment the lines below to customize script behavior)

trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM

# Trap errors in subshells and functions
set -o errtrace

# Exit on error. Append '||true' if you expect an error
set -o errexit

# Use last non-zero exit code in a pipeline
set -o pipefail

# Confirm we have BASH greater than v4
[ "${BASH_VERSINFO:-0}" -ge 4 ] || {
    printf "%s\n" "ERROR: BASH_VERSINFO is '${BASH_VERSINFO:-0}'.  This script requires BASH v4 or greater."
    exit 1
}

# Make `for f in *.txt` work when `*.txt` matches zero files
shopt -s nullglob globstar

# Set IFS to preferred implementation
IFS=$' \n\t'

# Run in debug mode
# set -o xtrace

# Source utility functions
_sourceUtilities_ "$(_findBaseDir_)/../shell-scripting-templates/utilities"

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

# Add Homebrew bin directory to PATH (MacOS)
# _homebrewPath_

# Source GNU utilities from Homebrew (MacOS)
# _useGNUutils_

# Run the main logic script
_mainScript_

# Exit cleanly
_safeExit_
