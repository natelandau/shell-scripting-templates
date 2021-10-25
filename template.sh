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

}

#/_mainsScript_()

# ################################## Flags and defaults
# Script specific

# # Required variables
LOGFILE="${HOME}/logs/$(basename "$0").log"
QUIET=false
LOGLEVEL=ERROR
VERBOSE=false
FORCE=false
DRYRUN=false
declare -a ARGS=()

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

    if [[ "$(declare -f "fatal")" && "$(declare -f "_printFuncStack_")" ]]; then
        _funcstack="'$(echo "${_funcstack}" | sed -E 's/ / < /g')'"
        if [[ ${_script##*/} == "${_sourced##*/}" ]]; then
            fatal "${7:-} command: '${_command}' (line: ${_line}) [func: $(_printFuncStack_)]"
        else
            fatal "${7:-} command: '${_command}' (func: ${_funcstack} called at line ${_linecallfunc} of '${_script##*/}') (line: ${_line} of '${_sourced##*/}') "
        fi
    else
        printf "%s\n" "Fatal error trapped. Exiting..."
    fi

    if [ "$(declare -f "_safeExit_")" ]; then
        _safeExit_ 1
    else
        exit 1
    fi
}

_sourceUtilities_() {
    # DESC:
    #					Sources bash utility functions
    # ARGS:
    #					$1 (required): Directories or files containing utility functions
    # OUTS:
    #					0 if success
    #         1 if failure
    # USAGE:
    #					_sourceHelperFiles_ "/path/to/dir" "path/to/file.sh"

    local _filesSourced=true

    [[ $# == 0 ]] && _filesSourced=false

    local _fileToSource
    local _location
    if [ ${_filesSourced} == true ]; then
        for _location in "$@"; do
            if [[ -d ${_location} ]]; then
                for _fileToSource in "${_location}"/*.{sh,bash}; do
                    if [[ -f ${_fileToSource} ]]; then
                        if ! source "${_fileToSource}"; then
                            _filesSourced=false
                            break 2
                        fi
                    else
                        _filesSourced=false
                        break 2
                    fi
                done
            elif [[ -f ${_location} ]] && [[ ${_location} =~ .*\.(sh|bash)$ ]]; then
                if ! source "${_fileToSource}"; then
                    _filesSourced=false
                    break
                fi
            else
                _filesSourced=false
                break
            fi
        done
    fi

    if [ ${_filesSourced} == true ]; then
        return 0
    else
        printf "%s\n" "ERROR: Invalid argument to ${FUNCNAME[0]}: ${_location}"
        if [ "$(declare -f "_safeExit_")" ]; then
            _safeExit_ 1
        else
            exit 1
        fi
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
                    if [[ ${_optstring} == *"${_c}:"* && ${1:i+1} ]]; then
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
                if [ "$(declare -f "_safeExit_")" ]; then
                    fatal "invalid option: $1"
                else
                    printf "%s\n" "Invalid option: $1"
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
_sourceUtilities_ "${HOME}/repos/shell-scripting-templates/utilities"

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

# Source GNU utilities for use on MacOS
# _useGNUutils_

# Run the main logic script
_mainScript_

# Exit cleanly
_safeExit_
